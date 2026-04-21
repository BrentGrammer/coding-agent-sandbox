#!/bin/bash

set -e

export OLLAMA_API_BASE="http://host.docker.internal:11434"
# export MODEL="qwen2.5-coder:14b"

echo "Checking Docker daemon..."
if ! docker info > /dev/null 2>&1; then
  echo "❌ Error: Docker is not running."
  echo "   Please start Docker Desktop and try again."
  exit 1
fi
echo "✅ Docker is running."

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