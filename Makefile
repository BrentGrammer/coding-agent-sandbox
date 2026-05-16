DOCKER_USER=brentgrammer
IMAGE_NAME=$(DOCKER_USER)/aider-sandbox
TAG=aider-ollama-v6
FULL_IMAGE=docker.io/$(IMAGE_NAME):$(TAG)

PROJECT=aider-sandbox

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

# Push to Docker Hub (Required because sbx pulls from registry)
push: build
	docker push $(IMAGE_NAME):$(TAG)

up: down
    ./allow_sbx_policies.sh
	# Run the sandbox
	sbx run --name $(PROJECT) --template $(FULL_IMAGE) shell .

agent:
	./start_agent.sh

down:
	sbx rm $(PROJECT) || true

clean:
	sbx rm $(PROJECT)
	docker images --format "{{.Repository}} {{.ID}}" | grep "^$(IMAGE_NAME)" | awk '{print $2}' | xargs -r docker rmi -f
	killall sbx
	pkill ollama