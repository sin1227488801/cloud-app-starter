ENVFLAG :=
ifneq ("$(wildcard .env)","")
ENVFLAG := --env-file .env
endif

TF_VERSION ?= 1.9.5
TF_IMAGE := hashicorp/terraform:$(TF_VERSION)
CLOUD ?= azure
WORKDIR := /workspace

docker-run = docker run --rm -it $(ENVFLAG) -v $(PWD):$(WORKDIR) -w $(WORKDIR) $(TF_IMAGE)

ifeq ($(CLOUD),azure)
ENV_DIR := envs/azure/azure-b1s-mvp
else ifeq ($(CLOUD),aws)
ENV_DIR := envs/aws/aws-ec2-mvp
else
$(error Unsupported CLOUD: $(CLOUD). Use azure or aws)
endif

docker-init:
	$(docker-run) -chdir=$(ENV_DIR) init -backend-config=backend.hcl || true

docker-plan:
	$(docker-run) -chdir=$(ENV_DIR) plan

docker-apply:
	$(docker-run) -chdir=$(ENV_DIR) apply -auto-approve

docker-destroy:
	$(docker-run) -chdir=$(ENV_DIR) destroy -auto-approve

fmt:
	$(docker-run) fmt -recursive

validate: docker-init
	$(docker-run) -chdir=$(ENV_DIR) validate
