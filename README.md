# A.I. Coding Agent setup

- See [MODELS.md](./MODELS.md) for reference and list of models to use and try.

Runs a fully sand-boxed A.I. agent using Aider and Ollama model for local A.I. model hosting using Docker Sandbox.
There is an empty `src/` folder where project files and source code can live. It also contains a readonly directory with .md files the agent can parse and bring into context using `/read` in aider.

- There are also some base helper scripts (start_codex.sh or start_gemini.sh) to setup a Docker Sandbox with Codex or Gemini CLI to try out other agents and options.
- Visit the other branches of this project to see implementations using Cloud based models like Gemini and OpenAI

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
- Ollama Model installed locally
  - `brew install ollama`
- Install the models (one time installation)
  - `brew serve ollama`
  - Leave that terminal window open. (If you close it, the server stops). Open a NEW terminal tab or window (Cmd + T) and pull in the model
    - `ollama pull qwen2.5-coder:14b`
      NOTE: if model changes remember to update the dockerfile env var: `ENV MODEL="qwen3.6:35b"` and increment the tag version in the Makefile for the image.

## Running the environment

- **IMPORTANT** Docker sandbox is proxy managed, so the host needs to contain the secrets, otherwise you may get authentication errors including "invalid API key":
  - on the host machine, set sbx secret containing your open ai api key with: `sbx secret set -g <llm-company-name>`
  - example: `sbx secret set -g openai` and enter your API key at the prompt. This will ensure requests sent from within the sandbox will work with your api keys in the headers. Docker sandbox is designed to use secrets stored in the host's secure keychain.
  - To use OpenAI Plus subscription for example, use: `sbx secret set -g openai --oauth`
- `make agent`
  - NOTE: if you make changes to the Dockerfile, increment the tag version
- start aider:

```shell
aider --model ollama/${MODEL} --yes --no-auto-commits
# to bring in all project initially:
aider --model ollama/${MODEL} --yes --no-auto-commits .

# or for newer models?
aider --model ollama_chat/${MODEL} --yes --no-auto-commits .

```

### Quitting Ollama

- In the running terminal, press CTRL-C
- Run `pkill ollama`

## Usage notes

- The environment uses Docker Sandbox and a map to the workspace project directory for mounting

### Recommended models

After pulling a new model, change the `MODEL=` line in `start-agent.sh` (e.g., `MODEL="qwen3-coder-next"`) and restart.

- qwen2.5-coder:14b -> base for ai coding agent - good balance between resource usage and performance
- qwen3-coder-next → biggest quality jump for agentic work.

```shell
# In start_aider.sh:

# MODEL="ollama/qwen2.5-coder:14b"
MODEL="ollama/qwen3.6:35b"
#MODEL="ollama/deepseek-r1:32b" # good for thinking and reasoning with complex .md instructions with design patterns etc.
#MODEL="ollama/qwen2.5-coder:32b" # good for fast boilerplate and refactors
# MODEL="gemini/gemini-3-pro-preview"
# MODEL="gemini/gemini-2.5-pro"
#MODEL="openai/gpt-5.4"
```

### Recommended Locked Down settings

- `docker sandbox network proxy --allow-host localhost`
- For Python: `docker sandbox network proxy --allow-host pypi.org --allow-host files.pythonhosted.org`
- For Node.js: `docker sandbox network proxy --allow-host registry.npmjs.org`
- If you get a Connection Refused or Network Unreachable error while the agent is working, just run this command on your Mac to fix it:
  `docker sandbox network proxy [sandbox-name] --allow-host [the-domain-it-tried-to-reach]`

Make sure your agent's environment variables are set like this so it doesn't try to look for Ollama in the wrong place:
`OLLAMA_HOST: http://host.docker.internal:11434`

- In "Locked Down" mode, if your agent tries to use a curl or git clone command to a site you haven't whitelisted, it will fail silently or hang. Keep an eye on your terminal for proxy block notifications!

## Aider Usage Tips

- [Configuring API Keys](https://aider.chat/docs/config/api-keys.html)

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
aider --model ollama/${MODEL} --yes --no-auto-commits .
```

- see chat mode options you can use: https://aider.chat/docs/usage/modes.html

### Make a Project Goal or Vision md file

- Make a .md file and make it read only to aider for overall project goal and vision
  - `/read PROJECT_GOAL.md`

  ### stopping sandbox
  - To free up RAM you can stop sandbox with: `killall sbx`

## Aider Flags

### Disable Analytics

You can opt out of analytics forever by running this command one time:
`aider --analytics-disable`

### Other flags that could be useful:

group.add_argument(
"--analytics-disable",
action="store_true",
help="Permanently disable analytics",
default=False,
)

group.add_argument(
"--install-main-branch",
action="store_true",
help="Install the latest version from the main branch",
default=False,
)

Windows?
group.add_argument(
"--line-endings",
choices=["platform", "lf", "crlf"],
default="platform",
help="Line endings to use when writing files (default: platform)",
)

group.add_argument(
"--env-file",
metavar="ENV_FILE",
default=default_env_file(git_root),
help="Specify the .env file to load (default: .env in git root)",
).complete = shtab.FILE
