#!/bin/bash

set -e

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

# Optional: Wait a tiny bit more and verify the server is responding
if ! curl -s http://localhost:11434/api/tags > /dev/null; then
  echo "Waiting a bit longer for Ollama to be ready..."
  sleep 4
fi

make push
make up