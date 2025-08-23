# ⚡ 5分でWebサイト公開 - クイックスタート

## 🎯 このファイルの目的
**プログラミング初心者でも5分でWebサイトを公開**

---

## 📋 必要なもの
- [ ] インターネット接続
- [ ] ブラウザ（Chrome、Edge、Firefox等）
- [ ] メールアドレス

---

## 🚀 手順（初回30分、2回目以降5分）

### Step 1: アカウント作成（初回のみ）
1. **GitHub**: https://github.com → Sign up
2. **Azure**: https://azure.microsoft.com/free/ → 無料で始める

### Step 2: Azure設定（初回のみ）
1. **Azure Portal**: https://portal.azure.com
2. **Service Principal作成**: 
   - Azure Active Directory → アプリの登録 → 新規登録
   - 名前: `cloud-app-starter-sp`
3. **認証情報メモ**: 4つの値をメモ帳に保存
   - アプリケーション（クライアント）ID
   - ディレクトリ（テナント）ID
   - クライアントシークレット（証明書とシークレット → 新規作成）
   - サブスクリプションID（サブスクリプション画面）
4. **権限設定**: サブスクリプション → IAM → 共同作成者ロール追加

### Step 3: プロジェクト準備
1. **フォーク**: https://github.com/sin1227488801/cloud-app-starter → Fork
2. **シークレット設定**: Settings → Secrets and variables → Actions
   - `ARM_CLIENT_ID`: アプリケーションID
   - `ARM_CLIENT_SECRET`: クライアントシークレット  
   - `ARM_SUBSCRIPTION_ID`: サブスクリプションID
   - `ARM_TENANT_ID`: テナントID

### Step 4: デプロイ
1. **インフラ構築**: Actions → terraform-apply → Run workflow
2. **サイトデプロイ**: Actions → app-deploy → Run workflow
3. **完成**: ログのWebsite URLをクリック

### Step 5: 削除（不要時）
1. **削除**: Actions → terraform-destroy → Run workflow
2. **確認**: `confirm_destroy` に `DESTROY` と入力

---

## 🆘 困ったら

### 📚 詳細ガイド
- **完全初心者**: [docs/beginner-guide.md](docs/beginner-guide.md)
- **詳細手順**: [docs/quick-start.md](docs/quick-start.md)

### ❌ よくあるエラー
- **認証エラー**: シークレット設定を再確認
- **権限エラー**: Azure権限設定を再確認
- **その他**: 削除してから再実行

---

## 🎉 成功例
**作成されるサイト**: https://cloudappdevohgqvfjy.z11.web.core.windows.net/

---

**🚀 今すぐ始めましょう！**