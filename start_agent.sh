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

# We no longer need to check or start Ollama!
echo "✅ Cloud Mode: Using Gemini"

make push
make up