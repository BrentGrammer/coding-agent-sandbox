#!/usr/bin/bash

# need to run chmod +x ./start_aider.sh
# ./start_aider.sh

set -e

if [ -f .env ]; then
  set -a
  source .env
  set -a
  echo "✅ Loaded environment from .env"
else
  echo "❌ Error: .env file not found!"
  exit 1
fi

if [ -z "$MODEL" ]; then
    echo "No MODEL is set in the environment. exiting..."
    exit 1
fi

echo "Starting Aider with model '$MODEL'..."
aider --model "$MODEL" --yes --no-auto-commits