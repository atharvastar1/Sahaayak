FROM python:3.9-slim

# Set working directory
WORKDIR /app

# Install system dependencies (needed for FAISS and git)
RUN apt-get update && apt-get install -y \
    build-essential \
    libopenblas-dev \
    libomp-dev \
    git \
    && rm -rf /var/lib/apt/lists/*

# Copy only the necessary files for dependency installation
COPY requirements.txt .

# Install dependencies (use HF mirror for pip if needed, but standard is fine)
# Note: sentence-transformers pulls torch. This can be large (800MB+).
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy the application code and data
COPY . .

# Set environment variables for HF Spaces
ENV APP_ENV=production
ENV SAHAAYAK_API_KEY=PROTOTYPE_MASTER_KEY
# [REPLACE_THIS] - In HF Secrets, you should add GROQ_API_KEY
ENV GROQ_API_KEY=""
ENV PORT=7860

# Expose the default HF Spaces port
EXPOSE 7860

# Command to run the FastAPI app
# We use --port 7860 as expected by HF
CMD ["/bin/sh", "-c", "OMP_NUM_THREADS=4 uvicorn main:app --host 0.0.0.0 --port 7860 --workers 1"]
