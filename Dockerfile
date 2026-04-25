FROM python:3.12-slim

RUN apt-get update && apt-get install -y \
    sudo git nodejs npm \
    && rm -rf /var/lib/apt/lists/*

# Create the 'agent' user (required by sbx for many templates)
RUN useradd -ms /bin/bash agent && \
    echo "agent ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    
# Install Aider globally
RUN pip install --no-cache-dir aider-chat

WORKDIR /app

COPY ./.aider.model.settings.yml .
RUN chown agent:agent /app
USER agent