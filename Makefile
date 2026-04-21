DOCKER_USER=brentgrammer
IMAGE_NAME=$(DOCKER_USER)/aider-sandbox
TAG=v3
FULL_IMAGE=docker.io/$(IMAGE_NAME):$(TAG)

PROJECT=aider-sandbox

build:
	docker build -t $(IMAGE_NAME):$(TAG) .

# Push to Docker Hub (Required because sbx pulls from registry)
push: build
	docker push $(IMAGE_NAME):$(TAG)

up:
	-sbx policy allow network localhost:11434
	-sbx policy allow network host.docker.internal:11434
	-sbx policy allow network registry.npmjs.org
	-sbx policy allow network debian.org
	-sbx policy allow network ports.ubuntu.com
	-sbx policy allow download.docker.com
	-sbx policy allow network pypi.org
	-sbx policy allow network files.pythonhosted.org
	-sbx policy allow network deb.debian.org
	-sbx policy allow network archive.ubuntu.com
	-sbx policy allow network security.ubuntu.com
	# Run the sandbox
	sbx run --name $(PROJECT) --template $(FULL_IMAGE) shell .

clean:
	sbx rm $(PROJECT)