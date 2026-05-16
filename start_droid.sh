#!/usr/bin/env bash
set -euo pipefail


# This doesn't work and looks like you need to get a subscription to use droid

MODEL="${MODEL:-openai/gpt-5.5}"
# MODEL="amazon-bedrock/zai.glm-5"
PROJECT_DIR="${1:-$PWD}"

PROJECT_BASENAME="$(basename "$PROJECT_DIR")"
SANDBOX_NAME="droid-${PROJECT_BASENAME//_/-}"

# One-time setup:
#   Droid uses Factory auth, not BYOK secret by default.
#
# Recommended:
#   sbx secret set -g droid
#
# Or per sandbox, if you prefer:
#   sbx secret set "$SANDBOX_NAME" droid
#
# Usage:
#   ./start-droid-sbx.sh /path/to/my_project
#
# Example sandbox name:
#   my_project -> droid-my-project

./allow_sbx_policies.sh

configure_privacy_flags() {
  echo "Configuring privacy/telemetry environment inside sandbox..."

  sbx exec -d "$SANDBOX_NAME" bash -c '
set -euo pipefail

touch /etc/sandbox-persistent.sh

sed -i "/# BEGIN droid privacy flags/,/# END droid privacy flags/d" /etc/sandbox-persistent.sh

cat >> /etc/sandbox-persistent.sh <<'"'"'EOF'"'"'
# BEGIN droid privacy flags
export DO_NOT_TRACK=1
export SBX_NO_TELEMETRY=1
# END droid privacy flags
EOF
' || true
}

echo "Starting Droid agent for project $PROJECT_BASENAME with model: $MODEL..."
echo "Sandbox name: $SANDBOX_NAME"
echo "Project dir: $PROJECT_DIR"
echo "!!! IMPORTANT !!! --- Authenticate Droid with: 'sbx secret set -g droid' or use Factory OAuth on first run ---"

if sbx ls | grep -q "$SANDBOX_NAME"; then
  echo "✅ Existing sandbox found: $SANDBOX_NAME"
  echo "Reconnecting..."

  configure_privacy_flags

  sbx run "$SANDBOX_NAME"
else
  echo "🆕 Creating new sandbox: $SANDBOX_NAME"

  sbx create droid "$PROJECT_DIR" --name "$SANDBOX_NAME"

  configure_privacy_flags

  sbx run "$SANDBOX_NAME"
fi