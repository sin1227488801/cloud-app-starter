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

# README.mdに記載されているコマンド
up-azure:
	@echo "🚀 Setting up Azure infrastructure..."
	$(MAKE) docker-init CLOUD=azure
	$(MAKE) docker-apply CLOUD=azure

down-azure:
	@echo "🗑️ Destroying Azure infrastructure..."
	@echo "⚠️  WARNING: This will destroy ALL Azure resources!"
	@echo "Press Ctrl+C within 10 seconds to cancel..."
	@sleep 10
	$(MAKE) docker-destroy CLOUD=azure

app-deploy:
	@echo "📦 Deploying application..."
	@if [ -d "app" ]; then \
		echo "App directory found, deployment would be handled by CI/CD"; \
		echo "For manual deployment, use: az storage blob upload-batch"; \
	else \
		echo "No app directory found"; \
	fi

url-azure:
	@echo "🌐 Getting Azure website URL..."
	@$(docker-run) -chdir=$(ENV_DIR) output -raw static_website_url 2>/dev/null || echo "No URL output available. Run 'make up-azure' first."

# 既存のコマンド
docker-init:
	$(docker-run) -chdir=$(ENV_DIR) init -backend-config=backend.hcl || true

docker-plan:
	$(docker-run) -chdir=$(ENV_DIR) plan

docker-apply:
	$(docker-run) -chdir=$(ENV_DIR) apply -auto-approve

docker-destroy:
	@echo "🗑️ Initializing for destruction..."
	@# ローカルstateを使用（backend設定なし）
	@$(docker-run) -chdir=$(ENV_DIR) init -reconfigure -backend=false || true
	@echo "🗑️ Planning destruction..."
	@$(docker-run) -chdir=$(ENV_DIR) plan -destroy
	@echo "⚠️  Final confirmation: Press Enter to destroy, Ctrl+C to cancel"
	@read
	@$(docker-run) -chdir=$(ENV_DIR) destroy -auto-approve

fmt:
	$(docker-run) fmt -recursive

validate: docker-init
	$(docker-run) -chdir=$(ENV_DIR) validate

# ヘルプ
help:
	@echo "Available commands:"
	@echo ""
	@echo "🚀 One-click commands:"
	@echo "  up-azure     - Deploy Azure infrastructure"
	@echo "  down-azure   - Destroy Azure infrastructure (with confirmation)"
	@echo "  app-deploy   - Deploy application (handled by CI/CD)"
	@echo "  url-azure    - Get Azure website URL"
	@echo ""
	@echo "🔧 Development commands:"
	@echo "  docker-plan  - Run terraform plan"
	@echo "  docker-apply - Run terraform apply"
	@echo "  docker-destroy - Run terraform destroy"
	@echo "  fmt          - Format terraform files"
	@echo "  validate     - Validate terraform configuration"
	@echo ""
	@echo "⚠️  WARNING: down-azure will destroy ALL resources!"
