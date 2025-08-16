TF_IMAGE := hashicorp/terraform:1.9.5
ENVFILE ?= .env
CLOUD ?= azure
WORKDIR := /workspace

docker-run = docker run --rm -it --env-file $(ENVFILE) -v $(PWD):$(WORKDIR) -w $(WORKDIR) $(TF_IMAGE)

docker-init:
	$(docker-run) -chdir=envs/$(CLOUD) init -backend=false

docker-plan:
	$(docker-run) -chdir=envs/$(CLOUD) plan

docker-apply:
	$(docker-run) -chdir=envs/$(CLOUD) apply -auto-approve

docker-destroy:
	$(docker-run) -chdir=envs/$(CLOUD) destroy -auto-approve

fmt:
	$(docker-run) fmt -recursive

validate:
	$(docker-run) -chdir=envs/$(CLOUD) validate
