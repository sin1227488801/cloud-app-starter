#!/usr/bin/env bash
# GitHubシークレットの確認用スクリプト

set -euo pipefail

echo "=== GitHub Secrets確認 ==="

# GitHub CLI認証確認
if ! gh auth status >/dev/null 2>&1; then
    echo "❌ GitHub認証が必要です。'gh auth login'を実行してください。"
    exit 1
fi

echo "✅ GitHub認証確認済み"

# リポジトリ情報取得
REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
echo "📁 リポジトリ: $REPO"

echo ""
echo "=== 必要なシークレット一覧 ==="
REQUIRED_SECRETS=(
    "ARM_CLIENT_ID"
    "ARM_CLIENT_SECRET" 
    "ARM_SUBSCRIPTION_ID"
    "ARM_TENANT_ID"
)

for secret in "${REQUIRED_SECRETS[@]}"; do
    if gh secret list | grep -q "^$secret"; then
        echo "✅ $secret: 設定済み"
    else
        echo "❌ $secret: 未設定"
    fi
done

echo ""
echo "=== Azure認証情報確認 ==="
if az account show >/dev/null 2>&1; then
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    TENANT_ID=$(az account show --query tenantId -o tsv)
    
    echo "📋 現在のAzure設定:"
    echo "   Subscription ID: $SUBSCRIPTION_ID"
    echo "   Tenant ID: $TENANT_ID"
    
    echo ""
    echo "💡 シークレット設定コマンド例:"
    echo "   gh secret set ARM_SUBSCRIPTION_ID --body \"$SUBSCRIPTION_ID\""
    echo "   gh secret set ARM_TENANT_ID --body \"$TENANT_ID\""
    echo "   gh secret set ARM_CLIENT_ID --body \"<your-client-id>\""
    echo "   gh secret set ARM_CLIENT_SECRET --body \"<your-client-secret>\""
else
    echo "❌ Azure認証が必要です。'az login'を実行してください。"
fi

echo ""
echo "=== 完了 ==="