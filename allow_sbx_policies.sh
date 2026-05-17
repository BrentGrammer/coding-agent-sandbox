#!/usr/bin/env bash

# Policies to allow in docker sandbox when in locked down mode

# if blocked or package fails:
# run `sbx policy log`
# Then add only the blocked host that actually appears.

set -euo pipefail

# For hosting Ollama models locally:
sbx policy allow network -g localhost:11434
sbx policy allow network -g host.docker.internal:11434

# Allow Docker Hub access:
sbx policy allow download.docker.com:443

# Allow ubuntu security updates for patches and package upgrades
sbx policy allow network -g debian.org:443
sbx policy allow network -g ports.ubuntu.com:80
sbx policy allow network -g ports.ubuntu.com:443
sbx policy allow network -g deb.debian.org:443
sbx policy allow network -g archive.ubuntu.com:443
sbx policy allow network -g security.ubuntu.com:443

# Allow dependency registries
sbx policy allow network -g registry.npmjs.org:443
sbx policy allow network -g pypi.org:443
sbx policy allow network -g files.pythonhosted.org:443

# Allow AWS Bedrock
sbx policy allow network -g bedrock-runtime.us-west-2.amazonaws.com:443
sbx policy allow network -g bedrock-runtime.us-east-1.amazonaws.com:443

# Allow Google gemini
sbx policy allow network -g generativelanguage.googleapis.com:443
sbx policy allow network -g gemini-api-docs-mcp.dev:443
sbx policy allow network -g ai.google.dev:443
sbx policy allow network -g oauth2.googleapis.com:443
sbx policy allow network -g accounts.google.com:443
sbx policy allow network -g cloudcode-pa.googleapis.com:443
sbx policy allow network -g play.googleapis.com:443

# Allow OpenAI for codex Pro subscription
sbx policy allow network -g chatgpt.com:443
sbx policy allow network -g api.openai.com:443

# For Exa mcp
sbx policy allow network -g mcp.exa.ai:443

# Needed for Serena mcp - can remove after installing in the sandbox
sbx policy allow network -g github.com:443
sbx policy allow network -g api.github.com:443