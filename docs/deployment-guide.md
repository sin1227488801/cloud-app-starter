# デプロイメントガイド

## 🎯 現在の状況

✅ **準備完了**
- Terraformバックエンド設定修正済み
- 既存リソース確認済み（ストレージアカウントは再作成が必要）
- GitHubシークレット設定済み
- ワークフロー修正済み

## 🚀 デプロイ手順

### 1. terraform-applyワークフローの実行

1. GitHubリポジトリ（https://github.com/sin1227488801/cloud-app-starter）にアクセス
2. **Actions**タブをクリック
3. **terraform-apply**ワークフローを選択
4. **Run workflow**ボタンをクリック
5. **Run workflow**を実行

このワークフローで以下が実行されます：
- Terraformバックエンドの初期化
- 既存リソースのインポート
- 新しいストレージアカウントの作成
- 静的ウェブサイトの設定

### 2. app-deployワークフローの実行

terraform-applyが成功したら：

1. **app-deploy**ワークフローを選択
2. **Run workflow**ボタンをクリック
3. **Run workflow**を実行

このワークフローで以下が実行されます：
- ストレージアカウントの検出
- HTMLファイルのアップロード
- 静的ウェブサイトの公開

## 📊 期待される結果

### terraform-apply成功時
- ✅ リソースグループ: `cloud-app-starter-rg`
- ✅ 仮想ネットワーク: `cloud-app-starter-vnet`
- ✅ サブネット: `app`
- ✅ ストレージアカウント: `cloudappdev[random]`（新規作成）

### app-deploy成功時
- ✅ HTMLファイルがアップロード済み
- ✅ 静的ウェブサイトが公開
- 🌐 アクセス可能なURL: `https://[storage-account].z11.web.core.windows.net/`

## 🔍 トラブルシューティング

### terraform-applyが失敗する場合
1. GitHubシークレットの確認: `bash scripts/check-secrets.sh`
2. Azure認証の確認: `az account show`
3. 権限の確認: Service Principalに適切な権限があるか

### app-deployが失敗する場合
1. terraform-applyが先に成功しているか確認
2. ストレージアカウントが作成されているか確認
3. ワークフローログでエラー詳細を確認

## 📞 サポート

問題が発生した場合：
1. GitHub Actionsのログを確認
2. `scripts/manual-import.sh`で手動確認
3. `scripts/check-secrets.sh`でシークレット確認

## 🎉 成功後の確認

デプロイ成功後、以下を確認してください：
1. Azure Portalでリソースが作成されていること
2. 静的ウェブサイトにアクセスできること
3. HTMLコンテンツが正しく表示されること