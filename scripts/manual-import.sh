#!/usr/bin/env bash
# 手動でリソースをimportするためのスクリプト

set -euo pipefail

TFDIR="envs/azure/azure-b1s-mvp"
RG_NAME="sre-iac-starter-rg"

# 環境変数チェック
: "${ARM_SUBSCRIPTION_ID:?ARM_SUBSCRIPTION_ID is required}"

echo "=== Manual Import Script ==="
echo "Subscription ID: $ARM_SUBSCRIPTION_ID"
echo "Resource Group: $RG_NAME"
echo "Terraform Dir: $TFDIR"
echo ""

# Terraformの初期化
echo "Initializing Terraform..."
terraform -chdir="$TFDIR" init

# 現在のstateを確認
echo ""
echo "Current Terraform state:"
terraform -chdir="$TFDIR" state list || echo "No resources in state"

echo ""
echo "=== Starting Import Process ==="

# Resource Group
echo ""
echo "1. Importing Resource Group..."
RG_ID="/subscriptions/$ARM_SUBSCRIPTION_ID/resourceGroups/$RG_NAME"
if az group show -n "$RG_NAME" >/dev/null 2>&1; then
    echo "Resource Group exists: $RG_NAME"
    if terraform -chdir="$TFDIR" state show module.network.azurerm_resource_group.rg >/dev/null 2>&1; then
        echo "✅ Already in state"
    else
        echo "Importing..."
        terraform -chdir="$TFDIR" import module.network.azurerm_resource_group.rg "$RG_ID"
        echo "✅ Imported successfully"
    fi
else
    echo "ℹ️ Resource Group does not exist, will be created by apply"
fi

# VNet
echo ""
echo "2. Importing Virtual Network..."
VNET_NAME="sre-iac-starter-vnet"
if VNET_ID=$(az network vnet show -g "$RG_NAME" -n "$VNET_NAME" --query id -o tsv 2>/dev/null); then
    echo "VNet exists: $VNET_NAME"
    if terraform -chdir="$TFDIR" state show module.network.azurerm_virtual_network.vnet >/dev/null 2>&1; then
        echo "✅ Already in state"
    else
        echo "Importing..."
        terraform -chdir="$TFDIR" import module.network.azurerm_virtual_network.vnet "$VNET_ID"
        echo "✅ Imported successfully"
    fi
else
    echo "ℹ️ VNet does not exist, will be created by apply"
fi

# Subnet
echo ""
echo "3. Importing Subnet..."
SUBNET_NAME="app"
if SUBNET_ID=$(az network vnet subnet show -g "$RG_NAME" --vnet-name "$VNET_NAME" -n "$SUBNET_NAME" --query id -o tsv 2>/dev/null); then
    echo "Subnet exists: $SUBNET_NAME"
    if terraform -chdir="$TFDIR" state show module.network.azurerm_subnet.app >/dev/null 2>&1; then
        echo "✅ Already in state"
    else
        echo "Importing..."
        terraform -chdir="$TFDIR" import module.network.azurerm_subnet.app "$SUBNET_ID"
        echo "✅ Imported successfully"
    fi
else
    echo "ℹ️ Subnet does not exist, will be created by apply"
fi

# Storage Account
echo ""
echo "4. Importing Storage Account..."
if SA_NAME=$(az storage account list --resource-group "$RG_NAME" --query "[?contains(name, 'sreiac')].name | [0]" -o tsv 2>/dev/null); then
    echo "Storage Account exists: $SA_NAME"
    if terraform -chdir="$TFDIR" state show module.static_site.azurerm_storage_account.static_site >/dev/null 2>&1; then
        echo "✅ Already in state"
    else
        SA_ID=$(az storage account show -g "$RG_NAME" -n "$SA_NAME" --query id -o tsv)
        echo "Importing..."
        terraform -chdir="$TFDIR" import module.static_site.azurerm_storage_account.static_site "$SA_ID"
        echo "✅ Imported successfully"
    fi

    # Storage Account Network Rules
    echo ""
    echo "5. Importing Storage Account Network Rules..."
    if terraform -chdir="$TFDIR" state show module.static_site.azurerm_storage_account_network_rules.static_site >/dev/null 2>&1; then
        echo "✅ Already in state"
    else
        SA_ID=$(az storage account show -g "$RG_NAME" -n "$SA_NAME" --query id -o tsv)
        echo "Importing..."
        terraform -chdir="$TFDIR" import module.static_site.azurerm_storage_account_network_rules.static_site "$SA_ID" || echo "⚠️ Network rules import failed (may not exist)"
    fi
else
    echo "ℹ️ Storage Account does not exist, will be created by apply"
fi

echo ""
echo "=== Import Complete ==="
echo ""
echo "Final state:"
terraform -chdir="$TFDIR" state list

echo ""
echo "Running plan to verify imports..."
terraform -chdir="$TFDIR" plan

echo ""
echo "✅ Manual import completed!"
echo "You can now run 'terraform apply' to create any missing resources."
