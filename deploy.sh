#!/bin/bash
# =============================================================================
# deploy.sh — Sahaayak Backend EC2 Setup Script
# Run once on a fresh EC2 instance (Ubuntu 22.04, t3.medium or g4dn.xlarge)
# =============================================================================

set -e  # exit on any error

echo "🚀 Sahaayak Backend Deployment Starting..."

# ── 1. System packages ─────────────────────────────────────────────────────────
sudo apt-get update -y
sudo apt-get install -y python3.11 python3.11-venv python3-pip git htop

# ── 2. App directory ───────────────────────────────────────────────────────────
sudo mkdir -p /opt/sahaayak
sudo chown ubuntu:ubuntu /opt/sahaayak

# Copy your backend files to /opt/sahaayak (run from your local machine):
# scp -r ./Backend\ Sahaayak/* ubuntu@YOUR_EC2_IP:/opt/sahaayak/

# ── 3. Python virtual env ─────────────────────────────────────────────────────
cd /opt/sahaayak
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt

# ── 4. Env file (fill in your values before running) ──────────────────────────
# cp .env.example .env
# nano .env   ← set GROQ_API_KEY and SAHAAYAK_API_KEY

# ── 5. Install systemd service (keeps app alive after reboot/crash) ───────────
sudo tee /etc/systemd/system/sahaayak.service > /dev/null <<'SERVICE'
[Unit]
Description=Sahaayak FastAPI Backend
After=network.target

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/sahaayak
EnvironmentFile=/opt/sahaayak/.env
ExecStart=/opt/sahaayak/venv/bin/uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1 --log-level info
Restart=always
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE

sudo systemctl daemon-reload
sudo systemctl enable sahaayak
sudo systemctl start sahaayak

echo "✅ Sahaayak service started!"
echo "   Check status: sudo systemctl status sahaayak"
echo "   View logs:    sudo journalctl -u sahaayak -f"
echo "   Health check: curl http://localhost:8000/health"
