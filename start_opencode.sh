#!/usr/bin/env bash
set -euo pipefail

MODEL="openai/gpt-5.5"
PROJECT_DIR="${1:-$PWD}"

PROJECT_BASENAME="$(basename "$PROJECT_DIR")"
SANDBOX_NAME="opencode-${PROJECT_BASENAME//_/-}"

# One-time setup per sandbox name:
#   Ex: sbx secret set <sandbox_name> openai
#
# Usage:
#   ./start-opencode-sbx.sh /path/to/my_project
#
# Example sandbox name:
#   my_project -> opencode-my-project

echo "Starting opencode agent for project $PROJECT_BASENAME with model: $MODEL..."

# Persist OpenCode/Docker telemetry-related env vars inside this sandbox.
# This is idempotent: it replaces any previous block managed by this script.
sbx exec -d "$SANDBOX_NAME" bash -c '
set -euo pipefail

touch /etc/sandbox-persistent.sh

sed -i "/# BEGIN opencode privacy flags/,/# END opencode privacy flags/d" /etc/sandbox-persistent.sh

cat >> /etc/sandbox-persistent.sh <<'"'"'EOF'"'"'
# BEGIN opencode privacy flags
export OPENCODE_DISABLE_SHARE=1
export OPENCODE_DISABLE_AUTOUPDATE=1
export OPENCODE_DISABLE_MODELS_FETCH=1
export DO_NOT_TRACK=1
export SBX_NO_TELEMETRY=1
# END opencode privacy flags
EOF
' || true

sbx run opencode "$PROJECT_DIR" \
  --name "$SANDBOX_NAME" \
  -- --model "$MODEL"