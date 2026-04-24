# A.I. Coding Agent setup with AWS BedRock

Runs a fully sand-boxed A.I. agent using Aider and taps into AWS Bedrock for using buffered cloud models like Deepseek.

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

- `make up`
  - NOTE: if you make changes to the Dockerfile, increment the tag version and push again with `make push`
- start aider:

```shell
aider --model ${MODEL} --yes --no-auto-commits
```

### Quitting Ollama

- In the running terminal, press CTRL-C
- Run `pkill ollama`

## Usage notes

- The environment uses Docker Sandbox and a map to the workspace project directory for mounting

### Recommended Locked Down settings

- `docker sandbox network proxy --allow-host localhost`
- For Python: `docker sandbox network proxy --allow-host pypi.org --allow-host files.pythonhosted.org`
- For Node.js: `docker sandbox network proxy --allow-host registry.npmjs.org`
- If you get a Connection Refused or Network Unreachable error while the agent is working, just run this command on your Mac to fix it:
  `docker sandbox network proxy [sandbox-name] --allow-host [the-domain-it-tried-to-reach]`

- In "Locked Down" mode, if your agent tries to use a curl or git clone command to a site you haven't whitelisted, it will fail silently or hang. Keep an eye on your terminal for proxy block notifications!

# AWS Bedrock setup

## Models

These names worked:
Deepseek R1: bedrock/converse/us.deepseek.r1-v1:0
Deepseek 3.2: bedrock/converse/deepseek.v3.2

DeepSeek on Bedrock is remarkably cheap compared to Anthropic or OpenAI. Since you are using a coding agent (Aider), costs are driven by "Context" (reading your files) and "Output" (writing the code).
Model Tier
Input (per 1M tokens)
Output (per 1M tokens)
DeepSeek-V3.2 / R1
~$0.60
~$1.85
DeepSeek-Distill (14B/32B)
~$0.20
~$0.45

### What does this look like in real life?

Small Task (Adding a single function): ~$0.01
Heavy Coding Session (1 hour of active back-and-forth): ~$0.25 to $0.75
Full Repo Analysis: If Aider reads 50 large files at once, you might spend $0.50 just on the initial "read." 3. How to Connect Aider to BedrockAider uses the litellm library under the hood to talk to AWS. Once you have your IAM keys, run these commands in your terminal:
Set your credentials:

```shell
export AWS_ACCESS_KEY_ID=your_access_key_here
export AWS_SECRET_ACCESS_KEY=your_secret_key_here
export AWS_REGION=us-east-1
```

Launch Aider with DeepSeek R1:
`aider --model bedrock/deepseek.r1`

### PROMPT CACHING

- Prompt Caching: In the Bedrock console, ensure "Prompt Caching" is enabled for your region. This can reduce your Input costs by up to 90% because Aider repeatedly sends the same file context.
- Model Access: You must go to the AWS Bedrock Console → "Model Access" and manually request/enable DeepSeek. It is not enabled by default.
- Region Lock: If your company has data residency requirements (e.g., data must stay in the EU), make sure to use eu-central-1 (Frankfurt) and update your IAM policy and export commands accordingly.

Using **Amazon Bedrock** is the most secure way to use DeepSeek in a corporate environment because it keeps your data within the AWS security boundary and legally guarantees that your code won't be used for model training.

### 1. How to use DeepSeek on AWS Bedrock

In 2026, DeepSeek is available as a **fully managed, serverless** model on Bedrock. You don't need to manage servers; you just pay for what you use.
**Step-by-Step Setup:**

1.  **Log in** to your AWS Management Console.

2.  **Get your API Keys:**

- `export AWS_BEARER_TOKEN_BEDROCK=...` to put the key in environment if needed

- Go to **IAM** in AWS.
- Create a user with AmazonBedrockFullAccess (?) permissions
  The "Least Privilege" IAM Policy
  Create a new IAM User (e.g., aider-bot) and attach this JSON policy to it. Replace us-east-1 with your preferred region.

  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "AllowBedrockDeepSeekInference",
        "Effect": "Allow",
        "Action": [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        "Resource": [
          "arn:aws:bedrock:us-east-1::foundation-model/deepseek.r1*",
          "arn:aws:bedrock:us-east-1::foundation-model/deepseek.v3*"
        ]
      },
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": "bedrock:ListFoundationModels",
        "Resource": "\*"
      }
    ]
  }
  ```

  or for newer models inference profiles might be required:

  ```json
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "BedrockInferenceProfileAccess",
        "Effect": "Allow",
        "Action": [
          "bedrock:InvokeModel",
          "bedrock:InvokeModelWithResponseStream"
        ],
        "Resource": [
          "arn:aws:bedrock:*:*:inference-profile/*deepseek*",
          "arn:aws:bedrock:*:*:inference-profile/*"
        ]
      },
      {
        "Sid": "BedrockListModelsAndInferenceProfiles",
        "Effect": "Allow",
        "Action": [
          "bedrock:ListFoundationModels",
          "bedrock:GetFoundationModel",
          "bedrock:ListInferenceProfiles"
        ],
        "Resource": "*"
      }
    ]
  }
  ```

- Generate **Access Key ID** and **Secret Access Key**.

4.  **Connect Aider:**

- Aider supports Bedrock natively. Run it with:

```bash
# Set up AWS CLI
aws configure --profile bedrock-api-user

# Or use environment variables (not necessary to make a profile this way)
export AWS_ACCESS_KEY_ID="existing-access-key"
export AWS_SECRET_ACCESS_KEY="existing-secret-key"
export AWS_REGION="us-east-1"

aider --model bedrock/deepseek.r1  # (Check specific model ID in AWS Console)
```
