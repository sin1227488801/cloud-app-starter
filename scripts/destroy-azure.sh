#!/bin/bash

# Azure リソース削除スクリプト
# 使用方法: bash scripts/destroy-azure.sh

set -euo pipefail

# 色付きログ関数
log() {
    echo -e "\033[36m[$(date +'%Y-%m-%d %H:%M:%S')] $1\033[0m"
}

warn() {
    echo -e "\033[33m[WARNING] $1\033[0m"
}

error() {
    echo -e "\033[31m[ERROR] $1\033[0m"
}

success() {
    echo -e "\033[32m[SUCCESS] $1\033[0m"
}

# 環境変数チェック
if [ ! -f ".env" ]; then
    error ".env file not found. Please create it from .env.example"
    exit 1
fi

# .envファイルを読み込み
set -a
source .env
set +a

# 必要な環境変数チェック
required_vars=("ARM_CLIENT_ID" "ARM_CLIENT_SECRET" "ARM_SUBSCRIPTION_ID" "ARM_TENANT_ID")
for var in "${required_vars[@]}"; do
    if [ -z "${!var:-}" ]; then
        error "Required environment variable $var is not set"
        exit 1
    fi
done

log "🗑️ Azure Resource Destruction Script"
log "======================================"

# 最終確認
warn "⚠️  WARNING: This will destroy ALL Azure resources!"
warn "Resources to be destroyed:"
warn "  - Resource Group: sre-iac-starter-rg"
warn "  - Storage Account: sreiacdev*"
warn "  - Virtual Network and Subnets"
warn "  - All associated resources"
echo ""
warn "This action CANNOT be undone!"
echo ""
read -p "Type 'DESTROY' to confirm: " confirmation

if [ "$confirmation" != "DESTROY" ]; then
    log "Destruction cancelled."
    exit 0
fi

log "🔑 Logging into Azure..."
az login --service-principal \
    --username "$ARM_CLIENT_ID" \
    --password "$ARM_CLIENT_SECRET" \
    --tenant "$ARM_TENANT_ID" > /dev/null

az account set --subscription "$ARM_SUBSCRIPTION_ID"

log "📋 Listing current resources..."
RESOURCE_GROUP="sre-iac-starter-rg"

# リソースグループの存在確認
if ! az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
    warn "Resource group '$RESOURCE_GROUP' not found. Nothing to destroy."
    exit 0
fi

# リソース一覧表示
log "Current resources in $RESOURCE_GROUP:"
az resource list --resource-group "$RESOURCE_GROUP" --output table

echo ""
read -p "Proceed with destruction? (y/N): " proceed
if [[ ! "$proceed" =~ ^[Yy]$ ]]; then
    log "Destruction cancelled."
    exit 0
fi

# Terraform経由での削除を試行
log "🏗️ Attempting Terraform destroy..."
TF_DIR="envs/azure/azure-b1s-mvp"

# ローカルstateでの初期化
if docker run --rm --env-file .env -v "${PWD}:/workspace" -w /workspace \
    hashicorp/terraform:1.9.5 -chdir="$TF_DIR" init -reconfigure -backend=false; then
    
    log "Planning destruction..."
    if docker run --rm --env-file .env -v "${PWD}:/workspace" -w /workspace \
        hashicorp/terraform:1.9.5 -chdir="$TF_DIR" plan -destroy -out=destroy.tfplan; then
        
        log "Executing destruction..."
        if docker run --rm --env-file .env -v "${PWD}:/workspace" -w /workspace \
            hashicorp/terraform:1.9.5 -chdir="$TF_DIR" apply destroy.tfplan; then
            success "✅ Terraform destroy completed successfully!"
        else
            warn "Terraform destroy failed. Attempting manual cleanup..."
        fi
    else
        warn "Terraform plan failed. Attempting manual cleanup..."
    fi
else
    warn "Terraform init failed. Attempting manual cleanup..."
fi

# 手動削除（フォールバック）
log "🧹 Manual cleanup of remaining resources..."

# Storage Account内のデータを削除
log "Cleaning up storage accounts..."
STORAGE_ACCOUNTS=$(az storage account list --resource-group "$RESOURCE_GROUP" \
    --query "[?contains(name, 'sreiac')].name" -o tsv 2>/dev/null || echo "")

for sa in $STORAGE_ACCOUNTS; do
    log "Cleaning storage account: $sa"
    
    # $webコンテナの内容を削除
    SA_KEY=$(az storage account keys list --account-name "$sa" --resource-group "$RESOURCE_GROUP" \
        --query '[0].value' -o tsv 2>/dev/null || echo "")
    
    if [ -n "$SA_KEY" ]; then
        log "Deleting blobs in \$web container..."
        az storage blob delete-batch --account-name "$sa" --account-key "$SA_KEY" \
            --source '$web' 2>/dev/null || true
    fi
done

# リソースグループ全体を削除
log "🗑️ Deleting resource group: $RESOURCE_GROUP"
if az group delete --name "$RESOURCE_GROUP" --yes --no-wait; then
    success "✅ Resource group deletion initiated!"
    log "Deletion is running in the background. It may take several minutes to complete."
else
    error "Failed to delete resource group. Manual cleanup may be required."
    exit 1
fi

# 削除状況の確認
log "🔍 Monitoring deletion progress..."
for i in {1..30}; do
    if ! az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
        success "✅ Resource group successfully deleted!"
        break
    fi
    log "Deletion in progress... ($i/30)"
    sleep 10
done

# 最終確認
if az group show --name "$RESOURCE_GROUP" > /dev/null 2>&1; then
    warn "Resource group still exists. Deletion may take longer than expected."
    log "You can check the status in Azure Portal or run:"
    log "az group show --name $RESOURCE_GROUP"
else
    success "🎉 All Azure resources have been successfully destroyed!"
fi

log "Destruction script completed."