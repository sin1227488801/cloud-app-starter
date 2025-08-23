# エラートラブルシューティングガイド

## 🎯 現在の状況

✅ **完了済み**

- 動的ダッシュボードの準備完了
- ストレージアップロード権限エラーの修正
- pre-commitフックによるコード品質チェック

## 🔍 よくあるエラーと解決策

### 1. Terraform関連エラー

#### エラー: "Backend initialization required"

```bash
Error: Backend initialization required, please run "terraform init"
```

**解決策:**

```bash
# .terraformディレクトリを削除して再初期化
rm -rf envs/azure/azure-b1s-mvp/.terraform
terraform -chdir=envs/azure/azure-b1s-mvp init -reconfigure
```

#### エラー: "Duplicate backend configuration"

```bash
Error: Duplicate backend configuration
```

**解決策:**

- `main.tf`と`backend.tf`の両方にバックエンド設定がある場合
- 片方のファイルからバックエンド設定を削除

### 2. Azure認証エラー

#### エラー: "Authentication failed"

```bash
ERROR: Please run 'az login' to setup account.
```

**解決策:**

```bash
# Azure CLIでログイン
az login

# サブスクリプション確認
az account show

# 必要に応じてサブスクリプション設定
az account set --subscription "your-subscription-id"
```

#### エラー: "You do not have the required permissions"

```bash
ERROR: You do not have the required permissions needed to perform this operation.
```

**解決策:**

- ストレージアカウントキー認証を使用（既に修正済み）
- Service Principalに適切なロールを付与

### 3. GitHub Actions関連エラー

#### エラー: "Secret not found"

```bash
Error: The secret 'ARM_CLIENT_ID' was not found
```

**解決策:**

```bash
# シークレット確認
bash scripts/check-secrets.sh

# 必要に応じてシークレット設定
gh secret set ARM_CLIENT_ID --body "your-client-id"
```

#### エラー: "Workflow file not found"

```bash
Error: .github/workflows/app-deploy.yaml not found
```

**解決策:**

- ファイルパスの確認
- ブランチが正しくマージされているか確認

### 4. ストレージアカウント関連エラー

#### エラー: "Storage account not found"

```bash
No storage account found in resource group
```

**解決策:**

```bash
# ストレージアカウント確認
az storage account list --resource-group cloud-app-starter-rg

# 手動でのリソース確認
bash scripts/manual-import.sh
```

#### エラー: "Container does not exist"

```bash
The specified container does not exist.
```

**解決策:**

- Terraformでstatic_websiteブロックが正しく設定されているか確認
- ストレージアカウントの静的ウェブサイト機能が有効になっているか確認

### 5. pre-commit関連エラー

#### エラー: "trailing-whitespace"

```bash
trim trailing whitespace.................................................Failed
```

**解決策:**

```bash
# 自動修正されるので、修正後に再コミット
git add .
git commit -m "fix: remove trailing whitespace" --no-verify
```

#### エラー: "pre-commit not found"

```bash
`pre-commit` not found. Did you forget to activate your virtualenv?
```

**解決策:**

```bash
# pre-commitをスキップしてコミット
git commit -m "your message" --no-verify
```

## 🛠️ デバッグ用コマンド

### Terraform状態確認

```bash
# 状態一覧
terraform -chdir=envs/azure/azure-b1s-mvp state list

# 特定リソースの詳細
terraform -chdir=envs/azure/azure-b1s-mvp state show module.static_site.azurerm_storage_account.static_site

# プラン実行
terraform -chdir=envs/azure/azure-b1s-mvp plan
```

### Azure リソース確認

```bash
# リソースグループ一覧
az group list --query "[?contains(name, 'sre-iac')].name" -o table

# ストレージアカウント一覧
az storage account list --resource-group cloud-app-starter-rg --query "[].{Name:name,Location:location,Kind:kind}" -o table

# 静的ウェブサイト設定確認
az storage blob service-properties show --account-name <storage-account-name> --query staticWebsite
```

### GitHub Actions確認

```bash
# ワークフロー実行履歴
gh run list --repo sin1227488801/cloud-app-starter

# 特定の実行詳細
gh run view <run-id> --repo sin1227488801/cloud-app-starter

# ログ確認
gh run view <run-id> --log --repo sin1227488801/cloud-app-starter
```

## 📞 サポート情報

### 有用なリンク

- [Azure CLI リファレンス](https://docs.microsoft.com/en-us/cli/azure/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [GitHub Actions ドキュメント](https://docs.github.com/en/actions)

### ログファイルの場所

- GitHub Actions: リポジトリのActionsタブ
- Terraform: `.terraform/` ディレクトリ
- Azure CLI: `~/.azure/logs/`

## 🎯 次のステップ

1. **現在のエラーを特定**
   - GitHub Actionsのログを確認
   - 具体的なエラーメッセージを取得

2. **該当する解決策を適用**
   - 上記のトラブルシューティングガイドを参照
   - 必要に応じて手動でのリソース確認

3. **修正後の検証**
   - ワークフローの再実行
   - 動的ダッシュボードでの状況確認
