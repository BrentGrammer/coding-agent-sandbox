#!/usr/bin/bash

# need to run chmod +x ./start_aider.sh
# ./start_aider.sh

set -e

#MODEL=bedrock/converse/zai.glm-5 # glm-5.1 - this one is fast!! but don't add extra config to aider.model.settings.yml for it - that slows it down.
# MODEL=bedrock/converse/moonshotai.kimi-k2.5 # or moonshot.kimi-k2-thinking
#MODEL=bedrock/converse/minimax.minimax-m2.5

#MODEL="bedrock/global.anthropic.claude-opus-4-7" # use inference profile
#MODEL="bedrock/us.anthropic.claude-opus-4-7" # use inference profile - this one works!

# MODEL=bedrock/converse/us.deepseek.r1-v1:0
# MODEL=bedrock/converse/deepseek.v3.2

# MODEL="ollama/qwen2.5-coder:14b"
#MODEL="ollama/qwen2.5-coder:7b" # try this for faster performance just coding.
#MODEL="ollama/qwen2.5-coder:14b" # slightly more powerful than above.
#MODEL="ollama/deepseek-r1:32b" # good for thinking and reasoning with complex .md instructions with design patterns etc.
#MODEL="ollama/qwen3.6:35b"
#MODEL="ollama/qwen3.6:35b-a3b" # might be faster than standard qwen 3.6?
#MODEL="ollama/qwen3.6:35b-a3b-coding-nvfp4"
#MODEL="ollama/qwen2.5-coder:32b" # good for fast boilerplate and refactors
#MODEL="ollama/qwen3.6:27b" # maybe faster than 32b?
#MODEL="ollama/qwen3.6:27b-q4_k_m" # takes less memory than the standard one above
#MODEL="ollama/gemma4:26b" # try this one for faster follow instructions from .md coding
#MODEL="gemini/gemini-3-pro-preview"
#MODEL="gemini/gemini-2.5-pro"
# MODEL="openai/gpt-5.4"

MODEL="o3-mini"

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
aider --model "$MODEL" --yes --no-auto-commits --analytics-disable