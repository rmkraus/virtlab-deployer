.PHONY : build _dockerfile publish clean clean_container clean_image run join start stop devel _devel_run

IMAGE=virtlab-deployer
VERS=$(shell cat app/version.txt)
NAME=$(IMAGE)_dev
DEVDIR=$(shell pwd)
UPSTREAM=$(shell cat upstream.txt)

build: clean _build_base _build_app
build_app: clean_app _build_app
build_base: clean_app _build_base
_build_base:
	podman build --pull -t $(IMAGE)-base:latest -f Dockerfile.base .
_build_app:
	podman build --pull -t $(IMAGE):dev .

clean: clean_container clean_app_image clean_base_image
clean_app: clean_container clean_app_image
clean_base: clean_base_image
clean_container:
	podman container rm "$(NAME)" || :
clean_app_image:
	podman image rm -f $(IMAGE):dev || :
clean_base_image:
	podman image rm -f $(IMAGE)-base:latest || :

publish:
	podman image tag $(IMAGE):dev $(UPSTREAM)/$(IMAGE):$(VERS)
	podman image tag $(IMAGE):dev $(UPSTREAM)/$(IMAGE):latest
	podman push $(UPSTREAM)/$(IMAGE):$(VERS)
	podman push $(UPSTREAM)/$(IMAGE):latest

run:
	podman run --name "$(NAME)" -it $(IMAGE):dev || podman start -ia "$(NAME)"

join:
	podman exec -it "$(NAME)" /bin/bash

start:
	podman start -ia "$(NAME)"

stop:
	podman stop "$(NAME)"

devel: clean_container _devel_run

_devel_run:
	podman run --name "$(NAME)" -v $(DEVDIR)/app:/app:Z -v $(DEVDIR)/data:/data:Z -it $(IMAGE):dev
