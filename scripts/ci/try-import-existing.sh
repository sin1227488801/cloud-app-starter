#!/usr/bin/env bash
set -euo pipefail

TFDIR="envs/azure/azure-b1s-mvp"
SUB_ID="${ARM_SUBSCRIPTION_ID:?}"
RG_NAME="sre-iac-starter-rg"
VNET_NAME="sre-iac-starter-vnet"
SUBNET_NAME="app"

# 既存RG?
set +e
RG_EXISTS=$(az group show -n "$RG_NAME" --query name -o tsv 2>/dev/null)
set -e
if [ -n "$RG_EXISTS" ]; then
  echo "[import] resource_group"
  terraform -chdir="$TFDIR" import -no-color \
    module.network.azurerm_resource_group.rg \
    "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME" || true
fi

# 既存VNet?
set +e
VNET_ID=$(az network vnet show -g "$RG_NAME" -n "$VNET_NAME" --query id -o tsv 2>/dev/null)
set -e
if [ -n "$VNET_ID" ]; then
  echo "[import] vnet"
  terraform -chdir="$TFDIR" import -no-color \
    module.network.azurerm_virtual_network.vnet "$VNET_ID" || true
fi

# 既存Subnet?
set +e
SUBNET_ID=$(az network vnet subnet show -g "$RG_NAME" --vnet-name "$VNET_NAME" -n "$SUBNET_NAME" --query id -o tsv 2>/dev/null)
set -e
if [ -n "$SUBNET_ID" ]; then
  echo "[import] subnet"
  terraform -chdir="$TFDIR" import -no-color \
    module.network.azurerm_subnet.app "$SUBNET_ID" || true
fi

# 静的サイト用 Storage Account はタグで推定（project=sre-iac-starter purpose=static-website）
set +e
SA_NAME=$(az storage account list --resource-group "$RG_NAME" \
  --query "[?tags.purpose=='static-website'].name | [0]" -o tsv 2>/dev/null)
set -e
if [ -n "$SA_NAME" ]; then
  SA_ID=$(az storage account show -g "$RG_NAME" -n "$SA_NAME" --query id -o tsv)
  echo "[import] storage_account ($SA_NAME)"
  terraform -chdir="$TFDIR" import -no-color \
    module.static_site.azurerm_storage_account.static_site "$SA_ID" || true

  # Network rules（存在時のみ・無ければTerraformが作る）
  set +e
  NR_ID=$(az resource list --resource-group "$RG_NAME" \
    --query "[?type=='Microsoft.Storage/storageAccounts'] | [?name=='$SA_NAME'].[id] | [0][0]" -o tsv 2>/dev/null)
  set -e
  if [ -n "$NR_ID" ]; then
    echo "[import] storage_account_network_rules"
    terraform -chdir="$TFDIR" import -no-color \
      module.static_site.azurerm_storage_account_network_rules.static_site "$NR_ID/blobServices/default" || true
  fi
fi

echo "[import] done (missing ones will be created by apply)"
