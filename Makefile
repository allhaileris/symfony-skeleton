include .env
DOCKER_BUILD_COMMAND=docker build --file Dockerfile --no-cache --platform linux/amd64 --tag $(APP_DOCKER_TAG)

dev:
	$(DOCKER_BUILD_COMMAND) --build-arg APP_ENV=dev .

prod:
	$(DOCKER_BUILD_COMMAND) --build-arg APP_ENV=prod .

stan:
	vendor/bin/phpstan analyse src

