#!/usr/bin/env bash
# 手動でのTerraform状態確認とインポート用スクリプト

set -euo pipefail

# 設定
TF_DIR="envs/azure/azure-b1s-mvp"
RG_NAME="sre-iac-starter-rg"
VNET_NAME="sre-iac-starter-vnet"
SUBNET_NAME="app"

echo "=== Manual Terraform Import Script ==="
echo "Working directory: $TF_DIR"

# Azure認証確認
if ! az account show >/dev/null 2>&1; then
    echo "❌ Azure認証が必要です。'az login'を実行してください。"
    exit 1
fi

echo "✅ Azure認証確認済み"

# 一時的にバックエンド設定をコメントアウト
echo "⚠️ 手動実行のため、一時的にローカルバックエンドを使用します"
cp "$TF_DIR/main.tf" "$TF_DIR/main.tf.bak"
sed 's/backend "azurerm" {}/# backend "azurerm" {}/' "$TF_DIR/main.tf.bak" > "$TF_DIR/main.tf"

# Terraform初期化
echo "🔄 Terraformを初期化中..."
rm -rf "$TF_DIR/.terraform"
terraform -chdir="$TF_DIR" init

echo "✅ Terraform初期化完了"

# 既存リソースの確認とインポート
echo ""
echo "=== 既存リソースの確認 ==="

# Resource Group
echo "1. Resource Group: $RG_NAME"
if az group show -n "$RG_NAME" >/dev/null 2>&1; then
    echo "   ✅ 存在します"
    if ! terraform -chdir="$TF_DIR" state show module.network.azurerm_resource_group.rg >/dev/null 2>&1; then
        echo "   📥 インポートを実行します..."
        terraform -chdir="$TF_DIR" import \
            module.network.azurerm_resource_group.rg \
            "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RG_NAME"
        echo "   ✅ インポート完了"
    else
        echo "   ✅ 既にTerraform状態に存在"
    fi
else
    echo "   ❌ 存在しません（Terraformで作成されます）"
fi

# Virtual Network
echo ""
echo "2. Virtual Network: $VNET_NAME"
if VNET_ID=$(az network vnet show -g "$RG_NAME" -n "$VNET_NAME" --query id -o tsv 2>/dev/null); then
    echo "   ✅ 存在します"
    if ! terraform -chdir="$TF_DIR" state show module.network.azurerm_virtual_network.vnet >/dev/null 2>&1; then
        echo "   📥 インポートを実行します..."
        terraform -chdir="$TF_DIR" import \
            module.network.azurerm_virtual_network.vnet "$VNET_ID"
        echo "   ✅ インポート完了"
    else
        echo "   ✅ 既にTerraform状態に存在"
    fi
else
    echo "   ❌ 存在しません（Terraformで作成されます）"
fi

# Subnet
echo ""
echo "3. Subnet: $SUBNET_NAME"
if SUBNET_ID=$(az network vnet subnet show -g "$RG_NAME" --vnet-name "$VNET_NAME" -n "$SUBNET_NAME" --query id -o tsv 2>/dev/null); then
    echo "   ✅ 存在します"
    if ! terraform -chdir="$TF_DIR" state show module.network.azurerm_subnet.app >/dev/null 2>&1; then
        echo "   📥 インポートを実行します..."
        terraform -chdir="$TF_DIR" import \
            module.network.azurerm_subnet.app "$SUBNET_ID"
        echo "   ✅ インポート完了"
    else
        echo "   ✅ 既にTerraform状態に存在"
    fi
else
    echo "   ❌ 存在しません（Terraformで作成されます）"
fi

# Storage Account
echo ""
echo "4. Storage Account (静的サイト用)"
if SA_NAME=$(az storage account list --resource-group "$RG_NAME" \
    --query "[?contains(name, 'sreiac')].name | [0]" -o tsv 2>/dev/null) && [ -n "$SA_NAME" ]; then
    echo "   ✅ 存在します: $SA_NAME"
    if ! terraform -chdir="$TF_DIR" state show module.static_site.azurerm_storage_account.static_site >/dev/null 2>&1; then
        echo "   📥 インポートを実行します..."
        SA_ID=$(az storage account show -g "$RG_NAME" -n "$SA_NAME" --query id -o tsv)
        terraform -chdir="$TF_DIR" import \
            module.static_site.azurerm_storage_account.static_site "$SA_ID"
        echo "   ✅ インポート完了"
    else
        echo "   ✅ 既にTerraform状態に存在"
    fi
else
    echo "   ❌ 存在しません（Terraformで作成されます）"
fi

echo ""
echo "=== Terraform Plan実行 ==="
terraform -chdir="$TF_DIR" plan

echo ""
echo "=== 完了 ==="

# バックエンド設定を復元
echo "🔄 バックエンド設定を復元中..."
mv "$TF_DIR/main.tf.bak" "$TF_DIR/main.tf"

echo "✅ インポート処理が完了しました。"
echo "💡 GitHub Actionsでリモートバックエンドを使用してデプロイしてください。"