# Start with a version that actually has Python 3.12
FROM python:3.12-slim

# Install the minimal system tools the sandbox needs
RUN apt-get update && apt-get install -y \
    sudo git nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Create the 'agent' user (required by sbx for many templates)
RUN useradd -ms /bin/bash agent && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    
# Install Aider globally
RUN pip install --no-cache-dir aider-chat

# Install Gemini Skills (Global)
# We use --yes to skip prompts during docker build
# RUN npx --yes skills add google-gemini/gemini-skills --skill gemini-api-dev --global

# This needs to match what you pulled on your host machine. pass the api key via a shell script, do not bake in since it is public
# ENV GEMINI_API_KEY="pass_in_shell_command" # this needs to be set somewhere at runtime not injected into the image.
# ENV MODEL="gemini/gemini-3-pro-preview"

# Set the working directory to where your code will be mounted
WORKDIR /app

COPY ./.aider.model.settings.yml .
RUN chown agent:agent /app/.aider.model.settings.yml

RUN chown agent:agent /app
USER agent