DOCKER_USER=brentgrammer
IMAGE_NAME=$(DOCKER_USER)/aider-sandbox
TAG=usegeminiv9
FULL_IMAGE=docker.io/$(IMAGE_NAME):$(TAG)

PROJECT=aider-sandbox

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

# Push to Docker Hub (Required because sbx pulls from registry)
push: build
	docker push $(IMAGE_NAME):$(TAG)

up: down
	-sbx policy allow network registry.npmjs.org
	-sbx policy allow network debian.org
	-sbx policy allow network ports.ubuntu.com
	-sbx policy allow network download.docker.com
	-sbx policy allow network pypi.org
	-sbx policy allow network files.pythonhosted.org
	-sbx policy allow network deb.debian.org
	-sbx policy allow network archive.ubuntu.com
	-sbx policy allow network security.ubuntu.com
	-sbx policy allow network generativelanguage.googleapis.com
	-sbx policy allow network gemini-api-docs-mcp.dev
	-sbx policy allow network ai.google.dev

	echo "🏗️  Creating sandbox in background..."
	sbx create --name $(PROJECT) --template $(FULL_IMAGE) shell .
	echo "🔐 Injecting keys into /etc/sandbox-persistent.sh..."
# 	sbx exec $(PROJECT) bash -c "echo 'export GEMINI_API_KEY=$$GEMINI_API_KEY' | sudo tee /etc/sandbox-persistent.sh"
# 	sbx exec $(PROJECT) bash -c "echo 'export MODEL=$$MODEL' | sudo tee -a /etc/sandbox-persistent.sh"
# 	sbx exec $(PROJECT) bash -c "echo 'export SBX_NO_TELEMETRY=1' | sudo tee -a /etc/sandbox-persistent.sh"
	echo "🚀 Everything is ready. Entering sandbox..."
	sbx run $(PROJECT)

agent:
	./start_agent.sh

down:
	sbx rm $(PROJECT)

clean:
	sbx rm $(PROJECT)
	docker images --format "{{.Repository}} {{.ID}}" | grep "^$(IMAGE_NAME)" | awk '{print $2}' | xargs -r docker rmi -f
	killall sbx
	pkill ollama