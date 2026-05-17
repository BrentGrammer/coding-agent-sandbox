#!/bin/bash

###############################################################################
# Gemini CLI OAuth Setup inside Docker SBX Locked-Down Sandbox
#
# Purpose:
# Use Gemini CLI with Google OAuth (subscription/account login)
# instead of an API key.
#
# Notes:
# - Do NOT use: sbx run gemini
# - Use: sbx run shell .
# - Gemini CLI may say "no sandbox"
#   because that refers to Gemini's internal sandbox,
#   not Docker SBX.
#
# First-Time Setup:
#
# 1. Remove Google API-key secret so Gemini uses OAuth:
#    sbx secret rm $SANDBOX_NAME google
#
# 2. Allow required network policies:
#    sbx policy allow network $SANDBOX_NAME registry.npmjs.org:443
#    sbx policy allow network $SANDBOX_NAME generativelanguage.googleapis.com:443
#    sbx policy allow network $SANDBOX_NAME oauth2.googleapis.com:443
#    sbx policy allow network $SANDBOX_NAME accounts.google.com:443
#    sbx policy allow network $SANDBOX_NAME play.googleapis.com:443
#    sbx policy allow network $SANDBOX_NAME cloudcode-pa.googleapis.com:443
#
# 3. CD into the project root folder and start a generic shell sandbox in your project:
#    sbx run shell . --name <sandbox-name>
# optionally update and upgrade 
#    sudo apt update
#    sudo apt upgrade -y
#
# 4. Inside the sandbox, install Gemini CLI:
#    npm install $SANDBOX_NAME @google/gemini-cli
#
# 5. Start Gemini CLI:
#    gemini
#
# 6. Choose:
#    "Sign in with Google"
#
################################################ 
#
# REUSING EXISTING SANDBOX (after setting it up initially using above instructions)
#
# 1. List existing sandboxes:
#    sbx ls
#
# 2. Reconnect to the existing sandbox:
#    sbx run <sandbox-name>
#
# Notes:
# - Gemini CLI install persists inside the sandbox.
# - OAuth login/session should persist inside the sandbox.
#
###############################################################################

SANDBOX_NAME="gemini-$(basename "$PWD")"

echo "Using sandbox name: $SANDBOX_NAME"

echo "Checking Docker daemon..."
if ! docker info > /dev/null 2>&1; then
  echo "Docker is not running. Attempting to start Docker Desktop..."
  echo 'If on Windows, quit this script and run: "C:\Program Files\Docker\Docker\Docker Desktop.exe"' 
  open -a Docker

  echo -n "Waiting for Docker to initialize"
  until docker info > /dev/null 2>&1; do
    echo -n "."
    sleep 2
  done

  echo -e "\n✅ Docker started successfully!"
else
  echo "✅ Docker is already running."
fi

code .

# Required policies for Gemini OAuth + Gemini CLI
sbx policy allow network $SANDBOX_NAME gemini-api-docs-mcp.dev:443
sbx policy allow network $SANDBOX_NAME ai.google.dev:443
sbx policy allow network $SANDBOX_NAME registry.npmjs.org:443
sbx policy allow network $SANDBOX_NAME generativelanguage.googleapis.com:443
sbx policy allow network $SANDBOX_NAME oauth2.googleapis.com:443
sbx policy allow network $SANDBOX_NAME accounts.google.com:443
sbx policy allow network $SANDBOX_NAME play.googleapis.com:443
sbx policy allow network $SANDBOX_NAME cloudcode-pa.googleapis.com:443

# Reuse existing sandbox if it already exists
if sbx ls | grep -q "$SANDBOX_NAME"; then
  echo "✅ Existing sandbox found: $SANDBOX_NAME"
  echo "Reconnecting..."
  echo "REMINDER: Once inside the sandbox, run the command 'GEMINI_TELEMETRY_ENABLED=false GEMINI_TELEMETRY_LOG_PROMPTS=false GEMINI_TELEMETRY_TRACES_ENABLED=false GEMINI_TELEMETRY_TARGET=local gemini' to start the cli."
  sbx run "$SANDBOX_NAME"
else
  echo "🆕 Creating new sandbox: $SANDBOX_NAME"
  sbx run shell . --name "$SANDBOX_NAME"
fi
# Disable telemetry
# GEMINI_TELEMETRY_ENABLED=false GEMINI_TELEMETRY_LOG_PROMPTS=false GEMINI_TELEMETRY_TRACES_ENABLED=false GEMINI_TELEMETRY_TARGET=local gemini [your-command]