# A.I. Coding Agent setup

Runs a fully sand-boxed A.I. agent using Aider and Gemini model using Docker Sandbox

## Pre-requisites

- [Docker Sandbox](https://docs.docker.com/ai/sandboxes/get-started/)
  - Recommended setting for permissions is Locked Down (balanced allows common apis, dependency managers, etc.)
    - Can change later with `sbx configure` if needed (?)
    - To change this anytime, run: `sbx policy reset`
      - To configure additional policies, run:
      ```shell
      sbx policy allow network <host>
      sbx policy deny network <host>
      ```
- Homebrew (macOS)

## Running the environment

- `make agent`
  - NOTE: if you make changes to the Dockerfile, increment the tag version and push again with `make push`
- `chmod +x ./start_aider.sh`
- `./start_aider.sh`

  OR

```shell
aider --model ${MODEL} --yes --no-auto-commits
# to bring in all project initially:
aider --model ${MODEL} --yes --no-auto-commits .
```

## models

- see https://models.litellm.ai/

Deepseek R1: bedrock/converse/us.deepseek.r1-v1:0
Deepseek 3.2: bedrock/converse/deepseek.v3.2
Gemini: gemini/gemini-2.5-pro
gemini/gemini-3-pro (not working?)
gemini/gemini-3-pro-preview

### Quitting Ollama

- In the running terminal, press CTRL-C
- Run `pkill ollama`
- `make clean` - removes sbx project and stops sbx and ollama

## Usage notes

- The environment uses Docker Sandbox and a map to the workspace project directory for mounting

### Recommended models

After pulling a new model, change the `MODEL=` line in `start-agent.sh` (e.g., `MODEL="qwen3-coder-next"`) and restart.

- qwen2.5-coder:14b -> base for ai coding agent - good balance between resource usage and performance
- qwen3-coder-next → biggest quality jump for agentic work.
- devstral (small or main) or glm-5.1 → Compare how they feel in real refactoring tasks.

### Recommended Locked Down settings

- `docker sandbox network proxy --allow-host localhost`
- For Python: `docker sandbox network proxy --allow-host pypi.org --allow-host files.pythonhosted.org`
- For Node.js: `docker sandbox network proxy --allow-host registry.npmjs.org`
- If you get a Connection Refused or Network Unreachable error while the agent is working, just run this command on your Mac to fix it:
  `docker sandbox network proxy [sandbox-name] --allow-host [the-domain-it-tried-to-reach]`

- In "Locked Down" mode, if your agent tries to use a curl or git clone command to a site you haven't whitelisted, it will fail silently or hang. Keep an eye on your terminal for proxy block notifications!

## Aider Usage Tips

- run `/ls` to see what files are added to its context
- use `/read PROJECT.md` to make a spec file readonly but in context

- run `/tokens` to view the context window for checking

- use `/clear` occasionally to clear the context window esp when using Ollama with Aider
- If you want Aider to know about a file but you don't want it to edit it (which saves tokens and prevents accidental bugs), use:

```Bash
/read-only path/to/file.py
```

- You can also launch Aider and tell it to include everything in the workspace folder immediately from your terminal:

```Bash
aider --model ${MODEL} --yes --no-auto-commits .
```

- see chat mode options you can use: https://aider.chat/docs/usage/modes.html

### Make a Project Goal or Vision md file

- Make a .md file and make it read only to aider for overall project goal and vision
  - `/read PROJECT_GOAL.md`

  ### stopping sandbox
  - To free up RAM you can stop sandbox with: `killall sbx`

## Troubleshooting

- Invalid API key - aider tries to use a Google Studio AI api key to connect to Google Vertex AI:
  - See .env.template file - need to explicitly clear VERTEX AI env variables
  - Use a GOOGLE_API_KEY in the environment as well
  - Specify the LITELLM_PROVIDER as gemini
