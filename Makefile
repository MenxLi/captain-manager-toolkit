
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/cuda/tags
IMAGE_NAME:=captain-cuda
CUDA_TAG:=12.1.1-cudnn8-devel-ubuntu22.04
EXTRA_BUILD_ARGS:=

JUMP_VOLUME:=captain_user_home
JUMP_IMAGE_NAME:=captain-jump
JUMP_CONTAINER_NAME:=jump

.PHONY: image

image:
	@echo "\033[92mBuilding Docker Image\033[0m"
	cd ./docker/base; \
	docker build --build-arg CUDA_TAG=$(CUDA_TAG) $(EXTRA_BUILD_ARGS) \
	-t $(IMAGE_NAME):$(CUDA_TAG) -f ./base.Dockerfile . ;\
	cd ../..

jump-build:
	@echo "\033[92mBuilding Jump Server Image\033[0m"
	cd ./docker/jump_server; \
	docker build -t ${JUMP_IMAGE_NAME}:latest . ;\
	cd ../..

# should first create the volume
# `docker volume create ${JUMP_VOLUME}`
jump-run:
	@if [ -z "$(shell docker volume ls -q -f name=${JUMP_VOLUME})" ]; then \
		echo "[ERROR] Docker volume '${JUMP_VOLUME}' does not exist. Please create it first."; \
		exit 1; \
	fi && \
	docker run -d -it --network=host \
		--cpus=4 -m=8g --volume=${JUMP_VOLUME}:/home \
		--restart=always --name=${JUMP_CONTAINER_NAME} \
		${JUMP_IMAGE_NAME}:latest

jump-add:
	@echo "Adding User to Jump Server"
	@read -p "Enter username: " USERNAME; \
	read -p "Enter public key: " PUBLIC_KEY; \
	docker exec -it ${JUMP_CONTAINER_NAME} /bin/bash -c "./create_user.sh $$USERNAME '$$PUBLIC_KEY'"
