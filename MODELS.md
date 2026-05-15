# Models Reference Guide

_This is a list of models to try (most tested with Aider)._

## Google Gemini

- `gemini/gemini-3-pro-preview`
- `gemini/gemini-2.5-pro`

## OpenAI

- `o3-mini`
- `openai/gpt-5.4`

## Amazon Bedrock

- `bedrock/converse/zai.glm-5` — **glm-5.1**: This one is fast!! but don't add extra config to `aider.model.settings.yml` for it - that slows it down.
- `bedrock/converse/moonshotai.kimi-k2.5` — Or `moonshot.kimi-k2-thinking`
- `bedrock/converse/minimax.minimax-m2.5`
- `bedrock/global.anthropic.claude-opus-4-7` — Use inference profile.
- `bedrock/us.anthropic.claude-opus-4-7` — Use inference profile - this one works!
- `bedrock/converse/us.deepseek.r1-v1:0`
- `bedrock/converse/deepseek.v3.2`

## Ollama (Local)

### Qwen

- `ollama/qwen2.5-coder:7b` — Try this for faster performance just coding.
- `ollama/qwen2.5-coder:14b` — Slightly more powerful than the 7b.
- `ollama/qwen2.5-coder:32b` — Good for fast boilerplate and refactors.
- `ollama/qwen3.6:27b` — Maybe faster than 32b?
- `ollama/qwen3.6:27b-q4_k_m` — Takes less memory than the standard 27b above.
- `ollama/qwen3.6:35b`
- `ollama/qwen3.6:35b-a3b` — Might be faster than standard Qwen 3.6?
- `ollama/qwen3.6:35b-a3b-coding-nvfp4`

### DeepSeek

- `ollama/deepseek-r1:32b` — Good for thinking and reasoning with complex `.md` instructions with design patterns, etc.

### Gemma

- `ollama/gemma4:26b` — Try this one to faster follow instructions from `.md` coding.
