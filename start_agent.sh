#!/bin/bash

set -e

export OLLAMA_API_BASE="http://host.docker.internal:11434"

if [ -f .env ]; then
  # automatically export all variables like api key
  set -a
  source .env
  set -a
  echo "✅ Loaded environment from .env"
else
  echo "❌ Error: .env file not found!"
  exit 1
fi

echo "Checking Docker daemon..."
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Attempting to start Docker Desktop..."
  echo 'If on Windows, quit this script and run: "C:\Program Files\Docker\Docker\Docker Desktop.exe"' 
  open -a Docker
  echo -n "Waiting for Docker to initialize..."
  until docker info > /dev/null 2>&1; do
    echo -n "."
    sleep 2
  done
  echo -e "\n✅ Docker started successfully!"
else
  echo "✅ Docker is already running."
fi

# Ensure Ollama is running on the host (GPU access)
echo "Checking Ollama..."


# optional - clean slate:
# echo "Resetting Ollama..."
# pkill ollama || true
# sleep 2

if ! pgrep -x "ollama" > /dev/null; then
  echo "Ollama is not running. Starting it in the background..."

  # kv cache type flag should help with performance
  OLLAMA_HOST="0.0.0.0:11434" OLLAMA_FLASH_ATTENTION="1" OLLAMA_KV_CACHE_TYPE="q8_0" ollama serve > /dev/null 2>&1 &
  sleep 5  # Give it a moment to start listening on port 11434

  echo "✅ Ollama started temporarily for this session (will stop when you quit)."
  echo "   (It will keep running until you reboot or run 'pkill ollama')"
else
  echo "✅ Ollama is already running."
fi

# Optional: Wait a tiny bit more and verify the server is responding
if ! curl -s http://localhost:11434/api/tags > /dev/null; then
  echo "Waiting a bit longer for Ollama to be ready..."
  sleep 4
fi

make push
make up