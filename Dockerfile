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
    
ENV OLLAMA_API_BASE="http://host.docker.internal:11434"

# Set the working directory to where your code will be mounted
WORKDIR /app
RUN chown agent:agent /app
USER agent