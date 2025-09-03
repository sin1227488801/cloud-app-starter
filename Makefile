ENVFLAG :=
ifneq ("$(wildcard .env)","")
ENVFLAG := --env-file .env
endif

TF_VERSION ?= 1.9.5
TF_IMAGE := hashicorp/terraform:$(TF_VERSION)
CLOUD ?= azure
WORKDIR := /workspace

docker-run = docker run --rm -it $(ENVFLAG) -v "$(PWD)":$(WORKDIR) -w $(WORKDIR) $(TF_IMAGE)

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
	@echo "📋 Using local state for development..."
	$(MAKE) docker-init-local CLOUD=azure
	$(MAKE) docker-apply CLOUD=azure

down-azure:
	@echo "🗑️ Destroying Azure infrastructure..."
	@echo "⚠️  WARNING: This will destroy ALL Azure resources!"
	@echo "Press Ctrl+C within 5 seconds to cancel..."
	@sleep 5
	$(MAKE) docker-init-local CLOUD=azure
	$(MAKE) docker-destroy CLOUD=azure
	$(MAKE) cleanup-local CLOUD=azure

app-deploy:
	@echo "📦 Deploying application..."
	@if [ -d "app" ]; then \
		STORAGE_ACCOUNT=$$($(docker-run) -chdir=$(ENV_DIR) output -raw storage_account_name 2>/dev/null); \
		if [ -n "$$STORAGE_ACCOUNT" ]; then \
			echo "🚀 Uploading files to $$STORAGE_ACCOUNT..."; \
			docker run --rm -it $(ENVFLAG) -v $(PWD):$(WORKDIR) -w $(WORKDIR) mcr.microsoft.com/azure-cli:latest sh -c \
				'az login --service-principal -u $$ARM_CLIENT_ID -p $$ARM_CLIENT_SECRET --tenant $$ARM_TENANT_ID > /dev/null && \
				 STORAGE_KEY=$$(az storage account keys list --account-name '$$STORAGE_ACCOUNT' --resource-group cloud-app-starter-rg --query "[0].value" -o tsv) && \
				 az storage blob upload-batch --account-name '$$STORAGE_ACCOUNT' --account-key "$$STORAGE_KEY" --source app --destination "$$web" --overwrite'; \
			echo "✅ Application deployed successfully!"; \
		else \
			echo "❌ Storage account not found. Run 'make up-azure' first."; \
		fi; \
	else \
		echo "❌ No app directory found"; \
	fi

url-azure:
	@echo "🌐 Getting Azure website URL..."
	@$(docker-run) -chdir=$(ENV_DIR) output -raw static_website_url 2>/dev/null || echo "No URL output available. Run 'make up-azure' first."

# 既存のコマンド
docker-init:
	@echo "🔧 Initializing Terraform with backend configuration..."
	$(docker-run) -chdir=$(ENV_DIR) init -backend-config=backend.hcl || true

docker-init-local:
	@echo "🔧 Initializing Terraform for local development..."
	@echo "📁 Using local configuration..."
	@# main.tfがリモート設定の場合はローカル設定に切り替え
	@if grep -q "backend \"azurerm\"" "$(ENV_DIR)/main.tf" 2>/dev/null; then \
		echo "❌ Remote configuration detected. Please use 'make cleanup-local' first to switch to local development."; \
		exit 1; \
	else \
		echo "✅ Already using local configuration"; \
	fi
	@# ローカルstateで初期化
	$(docker-run) -chdir=$(ENV_DIR) init -reconfigure

docker-plan:
	$(docker-run) -chdir=$(ENV_DIR) plan

docker-apply:
	$(docker-run) -chdir=$(ENV_DIR) apply -auto-approve

docker-destroy:
	@echo "🗑️ Planning destruction..."
	@$(docker-run) -chdir=$(ENV_DIR) plan -destroy
	@echo ""
	@echo "⚠️  FINAL CONFIRMATION REQUIRED ⚠️"
	@echo "This will permanently delete all Azure resources!"
	@echo "Type 'yes' to confirm destruction:"
	@bash -c 'read -p "> " confirm && [ "$$confirm" = "yes" ] || (echo "❌ Destruction cancelled" && exit 1)'
	@echo "🗑️ Destroying resources..."
	@$(docker-run) -chdir=$(ENV_DIR) destroy -auto-approve

cleanup-local:
	@echo "🧹 Cleaning up local configuration..."
	@# main.tfを元に戻す
	@if [ -f "$(ENV_DIR)/main.tf.remote" ]; then \
		rm -f "$(ENV_DIR)/main.tf"; \
		mv "$(ENV_DIR)/main.tf.remote" "$(ENV_DIR)/main.tf"; \
		echo "✅ Configuration restored to remote backend"; \
	else \
		echo "ℹ️  No remote configuration found, keeping current configuration"; \
	fi

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
