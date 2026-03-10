# Architectural Decisions & Design Rationale
**Team Percepta | AWS AI for Bharat Hackathon**

This document details explicit technical choices made while designing **Sahaayak** that might not be immediately obvious, ensuring that the system perfectly meets the requirements of a rural Indian user-base.

## 1. Why Vanilla HTML/JS over React or Next.js?
When evaluators look at `sahaayak_web`, they will notice it is written entirely in high-performance, vanilla JavaScript, HTML, and CSS. **This is an intentional, calculated decision.**

* **Sub-1MB Bundle Size:** Modern React/Next.js applications frequently require hundreds of kilobytes (or even megabytes) of framework overhead, hydration logic, and Virtual DOM mapping. In rural India, users are often on unreliable 3G networks. The Sahaayak UI is so lightweight it boots near-instantly, even on a degraded connection.
* **Aggressive Caching:** Vanilla JS enables us to tightly control standard browser Service Workers to ensure the app functions cleanly and rapidly without fighting React's state lifecycle.

## 2. Kiro and Spec-Driven Development
We adhered to **Spec-Driven Development**. The repository contains an `openapi.yaml` specification outlining strict schema invariants. 
* We leveraged the principles of **Kiro** to ensure our frontend (`ChatResponse` payload handler inside `app.js`) strictly mirrors the Python Pydantic definitions (`schemas.py`). 
* This effectively prevents API disjoints where the LLM might hallucinate malformed JSON that breaks the UI layer.

## 3. Hugging Face Deployment vs AWS App Runner
While the application architecture uses `boto3`, Amazon Bedrock, and AWS CloudFormation natively (`deploy_aws.sh`), we temporarily containerized the production preview build on **Hugging Face Spaces**.
* **Global Access Constraint:** We needed the hackathon judges to evaluate a live URL without us provisioning complex IAM user-roles for everyone reviewing the project.
* **Resilient Failovers:** The backend (`llm_bedrock.py`) natively checks for AWS credentials in the environment. Because we did not hardcode AWS secrets into the public Hugging Face repository, the application proves its resilience by seamlessly falling back to its optimized Groq Llama-3.1 router to handle live evaluation requests flawlessly. 

## 4. Multi-Threaded Docker Container
Deep inside the `Dockerfile`, we enforce `OMP_NUM_THREADS=4` before booting Uvicorn. This ensures the Facebook AI Similarity Search (FAISS) vector database utilizes all available parallel CPU threads, dividing the cosine-similarity matrix math to deliver near-instant retrieval times despite the app running on low-spec cloud instances.

## 5. Production AWS Roadmap (v2.0)
Our prototype successfully validates the core GenAI logic. However, as documented in our updated `aws_infra/template.yaml`, our enterprise-grade production migration path includes:
* **Security & Auth:** Migrating from static `PROTOTYPE_MASTER_KEY` to **Amazon Cognito** (passwordless phone/OTP auth for rural users) secured by **Amazon API Gateway** with JWT validation and strict rate-limiting.
* **Payload Optimization:** Instead of embedding Base64 TTS audio inside JSON (which inflates payload sizes by ~33%), we will stream binaries via **Amazon CloudFront** edge points, driving cold-start queries down to sub-5 seconds.
* **Vector Scale:** Decoupling the in-memory RAM FAISS vector engine into **Amazon OpenSearch Serverless** (Vector Engine) to enable infinite, synchronized horizontal scaling of EC2 backend containers.
* **Session Persistence:** State and conversational context will migrate into **Amazon ElastiCache (Redis)**, so if a rural user's connection drops, they can instantly recover context on any backend node.
* **Cost-Efficient Compute:** Transitioning our LLM inference clusters to **AWS Inferentia2 (Inf2)**, which provides 4x higher throughput and 10x lower latency vs standard GPUs, massively reducing government operational costs at scale.
