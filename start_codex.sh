#!/bin/bash

#### Helper script to start OpenAI Codex in docker sandbox. You need to set your OpenAI key with sbx secret set -g openai
  ## or sbx secret set -g --oauth and sign in with your account if you have a subscription.

#### cd into your project folder before running this. It will use that folder as what it has access to.

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

# requires logging in and setting secret (copy url this shows and login with Plus Subscription account):
#  sbx secret set -g openai --oauth
# you need this if in locked down mode in docker sandbox
sbx policy allow network "chatgpt.com"

sbx run codex -- --sandbox workspace-write --cd . -c analytics.enabled=false
