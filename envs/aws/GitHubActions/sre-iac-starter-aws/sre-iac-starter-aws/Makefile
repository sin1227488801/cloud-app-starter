SHELL := /bin/bash

bootstrap:
	cd envs/aws/backend-bootstrap && terraform init && terraform apply -auto-approve

plan:
	cd envs/aws/stacks/vm-basic && terraform init -backend-config=../backend.hcl && terraform plan

apply:
	cd envs/aws/stacks/vm-basic && terraform init -backend-config=../backend.hcl && terraform apply -auto-approve

destroy:
	cd envs/aws/stacks/vm-basic && terraform destroy -auto-approve
