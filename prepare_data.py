import pandas as pd
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer
import os
import numpy as np
from llm_embeddings import get_embeddings, bedrock_embeddings_available

# Create data directory if not exists
os.makedirs("data", exist_ok=True)

# 1. Load the CSV
csv_path = "data/schemes.csv"
if not os.path.exists(csv_path):
    print("CSV not found at data/schemes.csv. Please pull or copy it first.")
    exit(1)

df_raw = pd.read_csv(csv_path)

# 2. Rename columns to match retriever.py expectations
# (id,name,description,eligibility,benefits,link,category) -> (scheme_id, scheme_name, benefits, eligibility, schemeCategory)
df = pd.DataFrame()
df["scheme_id"] = df_raw["id"]
df["scheme_name"] = df_raw["name"]
df["benefits"] = df_raw["benefits"]
df["eligibility"] = df_raw["eligibility"]
df["schemeCategory"] = df_raw["category"]
df["description"] = df_raw["description"]

# 3. Create combined_text for retrieval
df["combined_text"] = df["scheme_name"] + " " + df["description"] + " " + df["benefits"] + " " + df["eligibility"]

# 4. Save as Parquet
parquet_path = "data/schemes_processed.parquet"
df.to_parquet(parquet_path)
print(f"Saved parquet to {parquet_path}")

# 5. Build FAISS Index
# We offer two modes: AWS Bedrock Titan (Preferred) or Local BGE (Fallback)
if bedrock_embeddings_available():
    print("🚀 Using AWS Bedrock Titan Embeddings for indexing...")
    docs = df["combined_text"].tolist()
    
    # Process in batches of 10 for efficiency
    batch_size = 10
    all_embeddings = []
    for i in range(0, len(docs), batch_size):
        batch = docs[i : i + batch_size]
        print(f"  Encoding batch {i//batch_size + 1}/{(len(docs)-1)//batch_size + 1}...")
        emb = get_embeddings(batch)
        if emb is not None:
            all_embeddings.append(emb)
        else:
            print("❌ Embedding failed for batch. Aborting.")
            exit(1)
            
    embeddings = np.vstack(all_embeddings)
    index_path = "data/faiss_titan_cosine.bin"
else:
    print("🏠 Using Local BGE Embeddings for indexing...")
    model = SentenceTransformer("BAAI/bge-small-en-v1.5")
    prefix = "Represent this sentence for searching relevant passages: "
    docs = [prefix + text for text in df["combined_text"].tolist()]
    
    print("Encoding documents...")
    embeddings = model.encode(docs, normalize_embeddings=True, convert_to_numpy=True)
    index_path = "data/faiss_bge_cosine.bin"

dim = embeddings.shape[1]
index = faiss.IndexFlatIP(dim) # Cosine similarity (Flat Inner Product on normalized vectors)
index.add(embeddings.astype("float32"))

faiss.write_index(index, index_path)
print(f"Saved FAISS index to {index_path}")
print("ALL DATA PREPARED SUCCESSFULLY!")
