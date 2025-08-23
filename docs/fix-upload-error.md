# アップロードエラーの修正

## 🔍 問題の特定

エラーメッセージ：
```
ERROR: You do not have the required permissions needed to perform this operation.
Depending on your operation, you may need to be assigned one of the following roles:
"Storage Blob Data Owner"
"Storage Blob Data Contributor"
"Storage Blob Data Reader"
"Storage Queue Data Contributor"
"Storage Queue Data Reader"
"Storage Table Data Contributor"
"Storage Table Data Reader"
If you want to use the old authentication method and allow querying for the right account key, please use the "--auth-mode" parameter and "key" value.
```

## 🔧 実施した修正

### 1. app-deploy.yamlの修正
- `az storage blob upload-batch`に`--auth-mode key`を追加
- ストレージアカウントキーを使用した認証に変更

### 2. terraform-apply.yamlの修正
- `--auth-mode login`から`--auth-mode key`に変更
- ストレージアカウントキーの取得処理を追加

## 📋 修正内容

### app-deploy.yaml
```yaml
# 修正前
if az storage blob upload-batch \
  --source "$SRC_DIR" \
  --destination '$web' \
  --overwrite; then

# 修正後
if az storage blob upload-batch \
  --source "$SRC_DIR" \
  --destination '$web' \
  --overwrite \
  --auth-mode key; then
```

### terraform-apply.yaml
```yaml
# 修正前
if az storage blob upload-batch \
  --account-name "$SA_NAME" \
  --source "$SRC_DIR" \
  --destination '$web' \
  --overwrite \
  --auth-mode login; then

# 修正後
echo "Getting storage account key..."
STORAGE_KEY=$(az storage account keys list \
  --account-name "$SA_NAME" \
  --resource-group "sre-iac-starter-rg" \
  --query '[0].value' \
  -o tsv)

if AZURE_STORAGE_ACCOUNT="$SA_NAME" AZURE_STORAGE_KEY="$STORAGE_KEY" \
  az storage blob upload-batch \
  --source "$SRC_DIR" \
  --destination '$web' \
  --overwrite \
  --auth-mode key; then
```

## 🚀 次のアクション

1. **app-deployワークフローの再実行**
   - GitHub Actionsで`app-deploy`ワークフローを再実行
   - 修正されたアップロード処理が動作することを確認

2. **結果の確認**
   - アップロードが成功することを確認
   - 静的ウェブサイトにアクセスできることを確認

## 💡 技術的な背景

### 認証方式の違い
- `--auth-mode login`: Azure AD認証（Service Principal）
- `--auth-mode key`: ストレージアカウントキー認証

### Service Principal権限の問題
Service Principalには以下のいずれかのロールが必要：
- Storage Blob Data Owner
- Storage Blob Data Contributor

しかし、ストレージアカウントキーを使用することで、この権限問題を回避できます。

## 🔒 セキュリティ考慮事項

- ストレージアカウントキーは強力な権限を持つため、適切に管理する必要があります
- 本番環境では、より細かい権限制御のためにAzure AD認証を推奨します
- 今回はデモ環境のため、シンプルなキー認証を使用しています