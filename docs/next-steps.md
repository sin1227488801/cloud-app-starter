# 次のステップ

## 🎯 現在の状況

✅ **完了済み**
- ストレージアップロード権限エラーの修正
- ワークフローファイルの更新（--auth-mode key使用）
- 変更のコミット・プッシュ完了

## 🚀 次に実行すべきアクション

### 1. Pull Requestの作成とマージ

**GitHub Webインターフェースで実行：**

1. https://github.com/sin1227488801/sre-iac-starter にアクセス
2. 「Compare & pull request」ボタンをクリック
3. PRタイトル: `fix: resolve storage upload permission error`
4. 説明:
   ```
   Fix Azure Storage upload permission error by changing from --auth-mode login to --auth-mode key
   
   - Change authentication method for storage uploads
   - Fix Terraform backend configuration duplication
   - Add comprehensive documentation
   ```
5. 「Create pull request」をクリック
6. 「Merge pull request」をクリックしてmainブランチにマージ

### 2. ワークフローの実行

**mainブランチにマージ後：**

1. **terraform-apply ワークフローを実行**
   - Actionsタブ → terraform-apply → Run workflow

2. **app-deploy ワークフローを実行**
   - terraform-apply成功後
   - Actionsタブ → app-deploy → Run workflow

### 3. 結果確認

**期待される結果：**
- ✅ ストレージアカウントキー認証でアップロード成功
- 🌐 静的ウェブサイトが公開される
- 🎨 app-landingの美しいランディングページが表示される

## 🔍 修正内容の詳細

### app-deploy.yaml
```yaml
# 修正箇所
if az storage blob upload-batch \
  --source "$SRC_DIR" \
  --destination '$web' \
  --overwrite \
  --auth-mode key; then  # ← loginからkeyに変更
```

### terraform-apply.yaml
```yaml
# 修正箇所
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
  --auth-mode key; then  # ← loginからkeyに変更
```

## 🎉 成功後の確認事項

1. **ワークフローログ確認**
   - "Upload successful!" メッセージが表示される
   - エラーメッセージが表示されない

2. **ウェブサイトアクセス**
   - ログに表示されるURLにアクセス
   - app-landingのランディングページが表示される

3. **Azure Portal確認**
   - ストレージアカウントの$webコンテナにファイルがアップロードされている

## 📞 トラブルシューティング

もしまだエラーが発生する場合：

1. **ストレージアカウントキー取得の確認**
   ```bash
   az storage account keys list --account-name [SA_NAME] --resource-group sre-iac-starter-rg
   ```

2. **手動でのアップロードテスト**
   ```bash
   az storage blob upload-batch --account-name [SA_NAME] --source app-landing --destination '$web' --auth-mode key
   ```

3. **Service Principal権限の確認**
   - Storage Account Contributorロールが付与されているか確認