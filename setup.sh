#!/bin/bash
set -e

echo "🚀 Updating apt package list..."
sudo apt update -y

echo "🐳 Installing Docker..."
sudo apt install -y docker.io



echo "✅ Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# --- Configuration ---
HOST_PORT=5678
HOST_PATH=/home/$(whoami)/n8n-data
TIMEZONE="Asia/Kolkata"
WEBHOOK_URL="https://exn8n1.ankitktool.com"

# 👇 Replace <YOUR_PERSONAL_ACCESS_TOKEN> with your GitHub token
GITHUB_REPO_URL="https://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@github.com/sykocode33/n8nwork.git"

echo "📁 Creating host path: $HOST_PATH"
mkdir -p "$HOST_PATH"

echo "🧹 Cleaning existing n8n data folder (if any)..."
rm -rf ${HOST_PATH}/*

echo "🌐 Downloading n8n data from GitHub repo..."
rm -rf /tmp/n8n-data-temp

if git clone $GITHUB_REPO_URL /tmp/n8n-data-temp; then
    echo "✅ Git clone succeeded."
else
    echo "❌ Git clone failed. Exiting."
    exit 1
fi

echo "📂 Copying n8n data to host path..."
cp -r /tmp/n8n-data-temp/* $HOST_PATH
rm -rf /tmp/n8n-data-temp

echo "🌐 Starting n8n Docker container..."

sudo docker run -d \
  --name n8n \
  -p ${HOST_PORT}:5678 \
  -v ${HOST_PATH}:/home/node/.n8n \
  -e TZ=${TIMEZONE} \
  -e N8N_WEBHOOK_URL=${WEBHOOK_URL} \
  n8nio/n8n

echo "✅ n8n is running at http://localhost:${HOST_PORT}"
