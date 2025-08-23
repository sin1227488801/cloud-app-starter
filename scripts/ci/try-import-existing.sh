#!/usr/bin/env bash
set -euo pipefail

TFDIR="envs/azure/azure-b1s-mvp"
SUB_ID="${ARM_SUBSCRIPTION_ID:?}"
RG_NAME="sre-iac-starter-rg"
VNET_NAME="sre-iac-starter-vnet"
SUBNET_NAME="app"

echo "=== Checking and importing existing resources ==="

# 既存RG?
set +e
RG_EXISTS=$(az group show -n "$RG_NAME" --query name -o tsv 2>/dev/null)
set -e
if [ -n "$RG_EXISTS" ]; then
  echo "[import] Checking if resource_group is already in state..."
  if ! terraform -chdir="$TFDIR" state show module.network.azurerm_resource_group.rg >/dev/null 2>&1; then
    echo "[import] Importing resource_group: $RG_NAME"
    if terraform -chdir="$TFDIR" import -no-color \
      module.network.azurerm_resource_group.rg \
      "/subscriptions/$SUB_ID/resourceGroups/$RG_NAME"; then
      echo "[import] ✅ Resource group imported successfully"
    else
      echo "[import] ⚠️ Resource group import failed, but continuing..."
    fi
  else
    echo "[import] ✅ Resource group already in state"
  fi
else
  echo "[import] ℹ️ Resource group does not exist, will be created"
fi

# 既存VNet?
set +e
VNET_ID=$(az network vnet show -g "$RG_NAME" -n "$VNET_NAME" --query id -o tsv 2>/dev/null)
set -e
if [ -n "$VNET_ID" ]; then
  echo "[import] Checking if vnet is already in state..."
  if ! terraform -chdir="$TFDIR" state show module.network.azurerm_virtual_network.vnet >/dev/null 2>&1; then
    echo "[import] Importing vnet: $VNET_NAME"
    if terraform -chdir="$TFDIR" import -no-color \
      module.network.azurerm_virtual_network.vnet "$VNET_ID"; then
      echo "[import] ✅ VNet imported successfully"
    else
      echo "[import] ⚠️ VNet import failed, but continuing..."
    fi
  else
    echo "[import] ✅ VNet already in state"
  fi
else
  echo "[import] ℹ️ VNet does not exist, will be created"
fi

# 既存Subnet?
set +e
SUBNET_ID=$(az network vnet subnet show -g "$RG_NAME" --vnet-name "$VNET_NAME" -n "$SUBNET_NAME" --query id -o tsv 2>/dev/null)
set -e
if [ -n "$SUBNET_ID" ]; then
  echo "[import] Checking if subnet is already in state..."
  if ! terraform -chdir="$TFDIR" state show module.network.azurerm_subnet.app >/dev/null 2>&1; then
    echo "[import] Importing subnet: $SUBNET_NAME"
    if terraform -chdir="$TFDIR" import -no-color \
      module.network.azurerm_subnet.app "$SUBNET_ID"; then
      echo "[import] ✅ Subnet imported successfully"
    else
      echo "[import] ⚠️ Subnet import failed, but continuing..."
    fi
  else
    echo "[import] ✅ Subnet already in state"
  fi
else
  echo "[import] ℹ️ Subnet does not exist, will be created"
fi

# 静的サイト用 Storage Account はタグで推定（project=sre-iac-starter purpose=static-website）
set +e
SA_NAME=$(az storage account list --resource-group "$RG_NAME" \
  --query "[?tags.purpose=='static-website'].name | [0]" -o tsv 2>/dev/null)
set -e

# タグで見つからない場合は、名前パターンで検索
if [ -z "$SA_NAME" ]; then
  set +e
  SA_NAME=$(az storage account list --resource-group "$RG_NAME" \
    --query "[?contains(name, 'sreiac')].name | [0]" -o tsv 2>/dev/null)
  set -e
fi

if [ -n "$SA_NAME" ]; then
  echo "[import] Checking if storage_account is already in state..."
  if ! terraform -chdir="$TFDIR" state show module.static_site.azurerm_storage_account.static_site >/dev/null 2>&1; then
    SA_ID=$(az storage account show -g "$RG_NAME" -n "$SA_NAME" --query id -o tsv)
    echo "[import] Importing storage_account: $SA_NAME"
    if terraform -chdir="$TFDIR" import -no-color \
      module.static_site.azurerm_storage_account.static_site "$SA_ID"; then
      echo "[import] ✅ Storage account imported successfully"
    else
      echo "[import] ⚠️ Storage account import failed, but continuing..."
    fi
  else
    echo "[import] ✅ Storage account already in state"
  fi

  # Network rules（存在時のみ・無ければTerraformが作る）
  echo "[import] Checking if storage_account_network_rules is already in state..."
  if ! terraform -chdir="$TFDIR" state show module.static_site.azurerm_storage_account_network_rules.static_site >/dev/null 2>&1; then
    SA_ID=$(az storage account show -g "$RG_NAME" -n "$SA_NAME" --query id -o tsv)
    echo "[import] Importing storage_account_network_rules for: $SA_NAME"
    if terraform -chdir="$TFDIR" import -no-color \
      module.static_site.azurerm_storage_account_network_rules.static_site "$SA_ID"; then
      echo "[import] ✅ Storage account network rules imported successfully"
    else
      echo "[import] ⚠️ Storage account network rules import failed, but continuing..."
    fi
  else
    echo "[import] ✅ Storage account network rules already in state"
  fi
else
  echo "[import] ℹ️ Storage account does not exist, will be created"
fi

echo "[import] === Import process completed ==="
