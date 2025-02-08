BASE_IMAGE_NAME:=ubuntu2204-cu121-base

base-image:
	@echo "\033[92mBuilding Docker Image\033[0m"
	cd ./docker; \
	docker build -t $(BASE_IMAGE_NAME) -f ./base.Dockerfile . ;\
	cd ..