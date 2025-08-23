#!/usr/bin/env bash
set -euo pipefail

# Inputs (env)
: "${TFSTATE_RG:=sre-iac-starter-tfstate-rg}"
: "${TFSTATE_LOC:=japaneast}"
: "${TFSTATE_SA:=}"  # 初回のみ実使用。既存あれば上書きしない
: "${TFSTATE_CONTAINER:=tfstate}"
: "${ARM_SUBSCRIPTION_ID:?}"
# ここでは az login は済として扱う（ワークフローで azure/login 実施後に呼ぶ）

# 既存探索：タグ/名前で拾う。既に作っていればそれを流用する
set +e
EX_RG=$(az group show -n "$TFSTATE_RG" --query name -o tsv 2>/dev/null)
set -e
if [ -z "$EX_RG" ]; then
  az group create -n "$TFSTATE_RG" -l "$TFSTATE_LOC" \
    --tags project=sre-iac-starter purpose=tfstate >/dev/null
fi

# 既存の tfstate 用ストレージアカウントをタグで探す
EX_SA=$(az storage account list \
  --resource-group "$TFSTATE_RG" \
  --query "[?tags.purpose=='tfstate'].name | [0]" -o tsv)

if [ -z "$EX_SA" ]; then
  # 新規作成 - ランダムサフィックスを生成（24文字制限に注意）
  if [ -z "$TFSTATE_SA" ]; then
    # 短いプレフィックス + 8文字のランダム = 最大16文字
    RANDOM_SUFFIX=$(date +%s | tail -c 4)$(shuf -i 1000-9999 -n 1 2>/dev/null || echo $((RANDOM % 9000 + 1000)))
    TFSTATE_SA="sreiac${RANDOM_SUFFIX}"
  fi
  
  # 24文字制限チェック
  if [ ${#TFSTATE_SA} -gt 24 ]; then
    echo "Error: Storage account name too long: $TFSTATE_SA (${#TFSTATE_SA} chars)"
    exit 1
  fi
  
  echo "Creating new storage account: $TFSTATE_SA"
  if ! az storage account create -g "$TFSTATE_RG" -n "$TFSTATE_SA" -l "$TFSTATE_LOC" \
    --sku Standard_LRS --kind StorageV2 \
    --tags project=sre-iac-starter purpose=tfstate >/dev/null; then
    echo "Error: Failed to create storage account $TFSTATE_SA"
    exit 1
  fi
  SA="$TFSTATE_SA"
else
  echo "Using existing storage account: $EX_SA"
  SA="$EX_SA"
fi

# コンテナ作成（存在すればOK）
az storage container create --name "$TFSTATE_CONTAINER" \
  --account-name "$SA" --auth-mode login >/dev/null

echo "TFSTATE_SA=$SA"
echo "TFSTATE_RG=$TFSTATE_RG"
echo "TFSTATE_CONTAINER=$TFSTATE_CONTAINER"
