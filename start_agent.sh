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
  echo "❌ Error: Docker is not running."
  exit 1
fi

# We no longer need to check or start Ollama!
echo "✅ Cloud Mode: Using Gemini"

make push
make up