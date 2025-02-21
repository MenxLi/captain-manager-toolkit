
IMAGE_NAME:=captain-cuda
CUDA_TAG:=12.1.1-cudnn8-devel-ubuntu22.04

.PHONY: image

image:
	@echo "\033[92mBuilding Docker Image\033[0m"
	cd ./docker; \
	docker build --build-arg CUDA_TAG=$(CUDA_TAG) \
	-t $(IMAGE_NAME):$(CUDA_TAG) -f ./base.Dockerfile . ;\
	cd ..