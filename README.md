# A.I. Coding Agent setup

Runs a fully sand-boxed A.I. agent using Aider with OpenAI's models

## Pre-requisites

- Docker
- [Docker Sandbox](https://docs.docker.com/ai/sandboxes/get-started/)
  - Recommended setting for permissions is Locked Down (balanced allows common apis, dependency managers, etc.)
    - Can change later with `sbx configure` if needed (?)
    - To change this anytime, run: `sbx policy reset`
      - To configure additional policies, run:
      ```shell
      sbx policy allow network <host>
      sbx policy deny network <host>
      ```

## Running the environment

- **IMPORTANT** Docker sandbox is proxy managed, so the host needs to contain the secrets: 
  - on the host machine, set sbx secret containing your open ai api key with: `sbx secret set -g openai`
- make sure you are in the project root and run `make agent`
  - NOTE: if you make changes to the Dockerfile, increment the tag version and push again with `make push`
- start aider:

```shell
# inside the sandbox after running make agent:
./start_aider.sh
```

## Usage notes

- The environment uses Docker Sandbox and a map to the workspace project directory for mounting

### Recommended Locked Down settings

- `docker sandbox network proxy --allow-host localhost`
- For Python: `docker sandbox network proxy --allow-host pypi.org --allow-host files.pythonhosted.org`
- For Node.js: `docker sandbox network proxy --allow-host registry.npmjs.org`
- If you get a Connection Refused or Network Unreachable error while the agent is working, just run this command on your Mac to fix it:
  `docker sandbox network proxy [sandbox-name] --allow-host [the-domain-it-tried-to-reach]`

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
