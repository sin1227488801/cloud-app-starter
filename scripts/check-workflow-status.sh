#!/usr/bin/env bash
# GitHub Actionsワークフローの状況確認スクリプト

set -euo pipefail

echo "=== GitHub Actions Workflow Status Check ==="

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
echo "=== 最新のワークフロー実行状況 ==="

# 最新の実行を取得
echo "🔄 terraform-apply ワークフロー:"
if TERRAFORM_RUN=$(gh run list --repo "$REPO" --workflow "terraform-apply" --limit 1 --json status,conclusion,createdAt,headBranch -q '.[0]' 2>/dev/null); then
    if [ "$TERRAFORM_RUN" != "null" ] && [ -n "$TERRAFORM_RUN" ]; then
        STATUS=$(echo "$TERRAFORM_RUN" | jq -r '.status')
        CONCLUSION=$(echo "$TERRAFORM_RUN" | jq -r '.conclusion')
        CREATED_AT=$(echo "$TERRAFORM_RUN" | jq -r '.createdAt')
        BRANCH=$(echo "$TERRAFORM_RUN" | jq -r '.headBranch')

        echo "   Status: $STATUS"
        echo "   Conclusion: $CONCLUSION"
        echo "   Branch: $BRANCH"
        echo "   Created: $CREATED_AT"

        if [ "$CONCLUSION" = "failure" ]; then
            echo "   ❌ 失敗しています"
        elif [ "$CONCLUSION" = "success" ]; then
            echo "   ✅ 成功しています"
        elif [ "$STATUS" = "in_progress" ]; then
            echo "   🔄 実行中です"
        fi
    else
        echo "   ℹ️ 実行履歴がありません"
    fi
else
    echo "   ⚠️ ワークフロー情報を取得できませんでした"
fi

echo ""
echo "🚀 app-deploy ワークフロー:"
if APP_RUN=$(gh run list --repo "$REPO" --workflow "app-deploy" --limit 1 --json status,conclusion,createdAt,headBranch -q '.[0]' 2>/dev/null); then
    if [ "$APP_RUN" != "null" ] && [ -n "$APP_RUN" ]; then
        STATUS=$(echo "$APP_RUN" | jq -r '.status')
        CONCLUSION=$(echo "$APP_RUN" | jq -r '.conclusion')
        CREATED_AT=$(echo "$APP_RUN" | jq -r '.createdAt')
        BRANCH=$(echo "$APP_RUN" | jq -r '.headBranch')

        echo "   Status: $STATUS"
        echo "   Conclusion: $CONCLUSION"
        echo "   Branch: $BRANCH"
        echo "   Created: $CREATED_AT"

        if [ "$CONCLUSION" = "failure" ]; then
            echo "   ❌ 失敗しています"
        elif [ "$CONCLUSION" = "success" ]; then
            echo "   ✅ 成功しています"
        elif [ "$STATUS" = "in_progress" ]; then
            echo "   🔄 実行中です"
        fi
    else
        echo "   ℹ️ 実行履歴がありません"
    fi
else
    echo "   ⚠️ ワークフロー情報を取得できませんでした"
fi

echo ""
echo "=== 推奨アクション ==="

# 失敗したワークフローがある場合の推奨アクション
if (echo "$TERRAFORM_RUN" | jq -r '.conclusion' 2>/dev/null | grep -q "failure") || \
   (echo "$APP_RUN" | jq -r '.conclusion' 2>/dev/null | grep -q "failure"); then
    echo "❌ 失敗したワークフローがあります。以下を確認してください："
    echo "   1. GitHub Actionsのログを確認"
    echo "   2. エラーメッセージを特定"
    echo "   3. docs/error-troubleshooting.md を参照"
    echo ""
    echo "🔍 ログ確認コマンド："
    echo "   gh run list --repo $REPO"
    echo "   gh run view <run-id> --log --repo $REPO"
else
    echo "✅ 現在のワークフロー状況は良好です"
    echo ""
    echo "🚀 次のステップ："
    echo "   1. PRをmainブランチにマージ"
    echo "   2. mainブランチでワークフローを実行"
    echo "   3. 動的ダッシュボードで結果確認"
fi

echo ""
echo "=== 完了 ==="
