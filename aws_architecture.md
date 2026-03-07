# Sahaayak — AWS Cloud Architecture
**Team Percepta | AI for Bharat Hackathon**

---

## System Overview

Sahaayak is a voice-first AI civic assistant powered by a hybrid AWS + local stack.
The architecture is designed for **scalability, fault tolerance, and cost efficiency** while
serving rural India's low-bandwidth environments.

---

## AWS Reference Architecture

```mermaid
flowchart TD
    subgraph USER["🧑‍🌾 End User"]
        A[Voice / WhatsApp / Web UI]
    end

    subgraph EDGE["Edge / Delivery"]
        B[Amazon CloudFront CDN]
        C[API Gateway / ALB]
    end

    subgraph COMPUTE["Compute — EC2 Auto-Scaling Group"]
        D[FastAPI Backend\nuvicorn · Python]
        E[Whisper STT\nLocal inference]
        F[gTTS / Polly\nText-to-Speech]
    end

    subgraph AI["AI Layer — AWS Cloud Native"]
        G[Amazon Nova Lite\nprimary LLM]
        H[Claude 3 Haiku\nhigh-quality fallback]
        G2[Amazon Bedrock Titan\nEmbeddings G1 v2]
        F2[Amazon Polly\nNeural TTS (Aditi)]
    end

    subgraph RAG["RAG Pipeline"]
        I[FAISS / Bedrock KB\nTitan vector search]
        J[BM25 Keyword Engine]
        K[Cross-Encoder Reranker]
    end

    subgraph STORAGE["Storage"]
        L[Amazon S3\naudio · logs · datasets]
        M[Amazon RDS PostgreSQL\nscheme data · user sessions]
        N[ElastiCache Redis\nRAG cache · session memory]
    end

    subgraph SERVERLESS["Serverless / Async"]
        O[AWS Lambda\nasync TTS jobs · feedback processing]
        P[Amazon SQS\njob queue]
    end

    subgraph SECURITY["Security"]
        Q[AWS WAF]
        R[AWS Secrets Manager\nAPI keys · DB credentials]
        S[IAM Roles\nleast-privilege]
    end

    A --> B --> C --> D
    D --> E
    D --> G
    D --> H
    D --> G2
    G2 --> I --> J --> K --> D
    D --> F --> L
    D --> M
    D --> N
    D --> P --> O
    Q --> C
    R --> D
    S --> G
```

---

## Service Breakdown

### Compute — Amazon EC2

| Component | Instance | Purpose |
|-----------|----------|---------|
| API Server | `t3.medium` | FastAPI + Uvicorn backend |
| ML Worker | `c5.xlarge` | Whisper STT + FAISS retrieval |
| Auto Scaling | Min 1, Max 5 | Handle peak load |

- **User Data script** auto-installs Python deps and starts uvicorn on boot
- **ALB health check** → `GET /health` (returns 200 when models ready)

### AI — Amazon Bedrock

| Model | ID | Usage |
|-------|----|-------|
| Amazon Nova Lite | `amazon.nova-lite-v1:0` | Primary LLM, fast + cost-efficient |
| Amazon Nova Pro | `amazon.nova-pro-v1:0` | High-quality fallback |
| Claude 3 Haiku | `anthropic.claude-3-haiku-20240307-v1:0` | Complex multi-turn queries |

- Activated by setting `AWS_REGION` + `BEDROCK_MODEL_ID` + AWS credentials in `.env`
- Falls back to Groq (llama-3.3-70b) automatically when Bedrock is unavailable

### Storage — Amazon S3

| Bucket | Contents |
|--------|----------|
| `sahaayak-audio-{env}` | TTS-generated audio files (TTL 24h lifecycle) |
| `sahaayak-logs-{env}` | Structured JSON request logs |
| `sahaayak-datasets-{env}` | Schemes CSV, FAISS index, embeddings |

### Database — Amazon RDS (PostgreSQL 15)

| Table | Contents |
|-------|----------|
| `schemes` | 3700+ government schemes with eligibility |
| `sessions` | Multi-turn conversation memory |
| `feedback` | User ratings for RLHF |

- `t3.micro` Multi-AZ for high availability
- Encrypted at rest (AWS KMS)

### Serverless — AWS Lambda + SQS

- **Async TTS**: Offload heavy audio generation to Lambda via SQS queue
- **Feedback processing**: Aggregate user feedback for model fine-tuning
- **Scheme refresh**: Nightly Lambda fetches scheme updates from MyScheme.gov.in

### Security

| Control | Implementation |
|---------|---------------|
| WAF | Block SQLi, XSS, rate-limit by IP |
| Secrets Manager | Rotate API keys on schedule |
| IAM | Least-privilege Bedrock role |
| VPC | Private subnet for RDS + Lambda |
| Encryption | TLS 1.3 in transit, AES-256 at rest |

---

## RAG Pipeline (AWS-aligned)

```
User Query (any Indian language)
    │
    ▼
[Amazon Transcribe / Whisper STT]
    │
    ▼
[Language Detection — script-based]
    │
    ▼
[Groq / Bedrock: Translate query to English]  ← for FAISS accuracy
    │
    ▼
[FAISS Dense Retrieval — Bedrock Titan]
    │
    ▼
[BM25 Keyword Search]
    │
    ▼
[RRF Hybrid Fusion]
    │
    ▼
[Cross-Encoder Reranker]
    │
    ▼
[Top-5 Schemes Retrieved]
    │
    ▼
[Amazon Bedrock — Nova Lite LLM]
    │
    ▼
[Response in User's Language]
    │
    ▼
[gTTS / Amazon Polly — Audio]
    │
    ▼
[User hears the answer 🎙️]
```

---

## Cost Estimate (Monthly, Production)

| Service | Config | Est. Cost |
|---------|--------|-----------|
| EC2 t3.medium | 1 instance, on-demand | ~$33 |
| EC2 c5.xlarge | 1 instance, Spot | ~$24 |
| Bedrock Nova Lite | 100K requests/mo | ~$5 |
| RDS t3.micro | Multi-AZ | ~$26 |
| S3 | 10 GB | ~$0.23 |
| CloudFront | 50 GB transfer | ~$4 |
| Lambda | 1M invocations | ~$0.20 |
| **Total** | | **~$92/month** |

---

## Scalability & Fault Tolerance

- **Auto Scaling**: EC2 ASG scales on CPU > 70% (max 5 instances)
- **ALB**: Routes to healthy instances; unhealthy ones removed automatically
- **Multi-AZ RDS**: Automatic failover in < 60 seconds
- **Bedrock → Groq fallback**: Zero downtime if Bedrock is throttled
- **ElastiCache**: LRU cache reduces Bedrock calls by ~40% for repeated queries
- **Low-bandwidth mode**: Audio is compressed MP3 (~12 KB per response)
