# 🚀 Phase3: CI/CD パイプライン構築チェックリスト

## 📋 事前準備

### GitHub設定

- [ ] GitHub CLI インストール・認証

  ```bash
  gh auth login
  gh auth status
  ```

- [ ] リポジトリ作成・設定

  ```bash
  gh repo create cloud-app-starter --private
  git remote add origin https://github.com/username/cloud-app-starter.git
  ```

### Secrets設定

- [ ] Azure認証情報をGitHub Secretsに設定

  ```bash
  gh secret set ARM_CLIENT_ID --body "your-client-id"
  gh secret set ARM_CLIENT_SECRET --body "your-client-secret"
  gh secret set ARM_SUBSCRIPTION_ID --body "your-subscription-id"
  gh secret set ARM_TENANT_ID --body "your-tenant-id"
  ```

- [ ] AWS認証情報設定（将来用）

  ```bash
  gh secret set AWS_ACCESS_KEY_ID --body "your-access-key"
  gh secret set AWS_SECRET_ACCESS_KEY --body "your-secret-key"
  ```

## 🔄 CI/CD ワークフロー実装

### 1. PR時自動プラン

- [ ] `.github/workflows/terraform-plan.yaml` 確認・調整
- [ ] PR作成時の自動実行テスト
- [ ] プラン結果のコメント表示確認

### 2. メイン自動デプロイ

- [ ] `.github/workflows/terraform-apply.yaml` 作成

  ```yaml
  name: terraform-apply
  on:
    push:
      branches: [main]
      paths: ["envs/**", "modules/**"]
  jobs:
    deploy:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: hashicorp/setup-terraform@v3
        - name: Terraform Apply
          run: |
            terraform -chdir=envs/azure/azure-b1s-mvp init
            terraform -chdir=envs/azure/azure-b1s-mvp apply -auto-approve
  ```

### 3. アプリ自動デプロイ

- [ ] `.github/workflows/app-deploy.yaml` 作成

  ```yaml
  name: app-deploy
  on:
    push:
      branches: [main]
      paths: ["app/**"]
  jobs:
    deploy:
      runs-on: ubuntu-latest
      steps:
        - uses: actions/checkout@v4
        - uses: azure/login@v1
        - name: Deploy to Static Website
          run: |
            SA_NAME=$(terraform -chdir=envs/azure/azure-b1s-mvp output -raw storage_account_name)
            az storage blob upload-batch --account-name "$SA_NAME" -s app -d '$web' --overwrite
  ```

## 🔐 セキュリティ強化

### Branch Protection

- [ ] メインブランチ保護設定

  ```bash
  gh api repos/:owner/:repo/branches/main/protection \
    --method PUT \
    --field required_status_checks='{"strict":true,"contexts":["terraform-plan"]}' \
    --field enforce_admins=true \
    --field required_pull_request_reviews='{"required_approving_review_count":1}'
  ```

### 環境分離

- [ ] GitHub Environments設定
  - [ ] `development` 環境
  - [ ] `production` 環境
- [ ] 環境別Secrets設定
- [ ] デプロイ承認フロー設定

## 📊 監視・通知

### デプロイ通知

- [ ] Slack/Teams通知設定
- [ ] デプロイ成功・失敗アラート
- [ ] PR時のプラン結果通知

### 監視設定

- [ ] Azure Monitor設定
- [ ] Application Insights設定
- [ ] コスト監視アラート設定

## 🧪 テスト自動化

### インフラテスト

- [ ] Terratest導入検討
- [ ] インフラ構成テスト
- [ ] セキュリティスキャン（tfsec/checkov）

### アプリテスト

- [ ] 静的サイトのリンクチェック
- [ ] パフォーマンステスト
- [ ] アクセシビリティテスト

## 🔄 リモートステート移行

### Azure Storage Backend

- [ ] Terraform State用Storage Account作成

  ```bash
  az group create --name tfstate-rg --location "Japan East"
  az storage account create --name tfstatesa --resource-group tfstate-rg
  az storage container create --name tfstate --account-name tfstatesa
  ```

- [ ] backend.hcl設定
- [ ] ローカルステートからの移行

  ```bash
  terraform init -migrate-state -backend-config=backend.hcl
  ```

### State Lock設定

- [ ] 同時実行防止設定
- [ ] CI/CD環境でのState管理

## 📈 運用改善

### ドキュメント自動化

- [ ] Terraform docs自動生成
- [ ] API仕様書自動更新
- [ ] 変更履歴自動記録

### コスト最適化

- [ ] 定期的なリソース棚卸し
- [ ] 未使用リソース自動削除
- [ ] コスト予算アラート

## ✅ 完了確認

### 動作テスト

- [ ] PR作成 → 自動プラン実行確認
- [ ] メインマージ → 自動デプロイ確認
- [ ] アプリ変更 → 自動デプロイ確認
- [ ] 失敗時のロールバック確認

### ドキュメント更新

- [ ] README.md更新
- [ ] 運用手順書作成
- [ ] トラブルシューティングガイド更新

## 🎯 成功指標

- [ ] デプロイ時間: 5分以内
- [ ] 成功率: 95%以上
- [ ] PR→本番: 30分以内
- [ ] ロールバック時間: 2分以内

## 📞 次のステップ

Phase3完了後:

1. **Phase4: 本格運用**
   - カスタムドメイン設定
   - CDN設定
   - 監視・アラート強化

2. **AWS環境展開**
   - マルチクラウド対応
   - DR（災害復旧）設定

3. **高度な自動化**
   - Infrastructure Testing
   - Chaos Engineering
   - 自動スケーリング
