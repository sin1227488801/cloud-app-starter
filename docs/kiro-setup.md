# 📖 SRE IaC Starter - 詳細セットアップガイド

このドキュメントは、SRE IaC Starterプロジェクトの詳細な設定手順とトラブルシューティングガイドです。

## 📊 進捗状況

- ✅ **Phase1**: 基盤整備完了 (Pre-commit, Lint, Terraform検証)
- ✅ **Phase2**: Azure Static Website デプロイ完了
- 🔄 **Phase3**: CI/CD パイプライン準備中
- ⏳ **Phase4**: 本格運用準備

## 🎯 成果物サマリー

### デプロイ済みリソース

- **Azure Static Website**: <https://sreiacdevm627ymaf.z11.web.core.windows.net/>
- **Storage Account**: sreiacdevm627ymaf
- **Resource Group**: sre-iac-starter-rg
- **Virtual Network**: sre-iac-starter-vnet (10.10.0.0/16)

### 月額コスト

- **現在**: ~¥10-100/月 (Azure Storage + データ転送)
- **将来**: ~¥500-2,000/月 (CDN + AWS環境追加時)

---

## 🚀 クイックスタート

### 前提条件

```bash
# 必要なツール
- Docker Desktop
- Git
- Azure Service Principal (認証用)
```bash

### 基本操作
```bash
# インフラ構築
make up-azure

# アプリデプロイ
make app-deploy

# URL確認
make url-azure

# 削除
make down-azure
```bash

---

## 🔧 認証情報設定

### Azure Service Principal作成
```bash
# 1. Azure CLIでログイン
az login

# 2. Service Principal作成
az ad sp create-for-rbac --name "terraform-sp" --role="Contributor" \
  --scopes="/subscriptions/$(az account show --query id -o tsv)"

# 3. 出力値を.envに設定
# ARM_CLIENT_ID=<appId>
# ARM_CLIENT_SECRET=<password>
# ARM_TENANT_ID=<tenant>
# ARM_SUBSCRIPTION_ID=<subscription-id>
```bash

### .env設定
```bash
cp .env.example .env
# 実際の認証情報を設定
```bash

---

## 📋 Phase1: 基盤整備 (完了)

### 実施内容
- ✅ Pre-commit hooks設定
- ✅ Terraform fmt/validate自動化
- ✅ Markdown/YAML lint設定
- ✅ Git属性・エディタ設定
- ✅ モジュール構造検証

### 品質チェック
```bash
# コード品質確認
pre-commit run --all-files

# Terraform検証
make validate CLOUD=azure
make fmt
```bash

---

## 🏗️ Phase2: Azure デプロイ (完了)

### 実施内容 （再掲）
- ✅ Azure Static Website モジュール実装
- ✅ ネットワーク・コンピュート・静的サイト統合
- ✅ ワンクリックデプロイ実装
- ✅ アプリ自動デプロイ機能

### 作成されたリソース
```bash
Azure Resources:
├── Resource Group: sre-iac-starter-rg
├── Virtual Network: sre-iac-starter-vnet (10.10.0.0/16)
├── Subnet: app (10.10.1.0/24)
└── Storage Account: sreiacdevm627ymaf
    └── Static Website: $web container
```bash

### デプロイコマンド
```bash
# 完全デプロイ
make up-azure && make app-deploy

# 個別操作
make docker-init CLOUD=azure
make docker-plan CLOUD=azure
make docker-apply CLOUD=azure
make app-deploy
```bash

---

## 🔄 Phase3: CI/CD パイプライン (準備中)

### 目標
- GitHub Actions自動化
- PR時の自動プラン実行
- マージ時の自動デプロイ
- Secrets安全管理

### 準備済み項目
- ✅ `.github/workflows/terraform-plan.yaml` (PR時プラン)
- ✅ Makefile統合
- ✅ Docker実行環境

### 実装予定
```bash
# GitHub認証設定
gh auth login

# Secrets設定
gh secret set ARM_CLIENT_ID
gh secret set ARM_CLIENT_SECRET
gh secret set ARM_SUBSCRIPTION_ID
gh secret set ARM_TENANT_ID

# ワークフロー有効化
git push origin main
```bash

---

## 🔐 リモートステート移行 (Phase3後)

### Azure Storage Backend
```bash
# 1. Storage Account作成
az group create --name tfstate-rg --location "Japan East"
az storage account create --name tfstatesa --resource-group tfstate-rg

# 2. backend.hcl更新
resource_group_name  = "tfstate-rg"
storage_account_name = "tfstatesa"
container_name       = "tfstate"
key                  = "azure-b1s-mvp.tfstate"

# 3. 移行実行
terraform init -migrate-state -backend-config=backend.hcl
```bash

---

## 🛠️ トラブルシューティング

### よくある問題

#### 1. 認証エラー
```bash
# 認証確認
az account show
docker run --rm --env-file .env mcr.microsoft.com/azure-cli az account show

# 解決方法
az login
# .envファイルの認証情報確認
```bash

#### 2. Storage Account名エラー
```bash
# 問題: 24文字制限超過
# 解決: modules/static-website/azure/main.tf で名前生成ロジック修正済み
```bash

#### 3. Terraform初期化エラー
```bash
# 解決方法
rm -rf .terraform/
terraform init
```bash

### ログ確認
```bash
# Terraform詳細ログ
TF_LOG=DEBUG terraform plan

# Azure CLI詳細ログ
az storage blob list --debug
```bash

---

## 📚 参考資料

### 公式ドキュメント
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Static Web Apps](https://docs.microsoft.com/azure/static-web-apps/)
- [GitHub Actions](https://docs.github.com/actions)

### プロジェクト固有
- [メインREADME](../README.md)
- [Terraform Plan結果](plan-azure.txt)
- [ウェブサイトURL](static-website-url.txt)

---

## 🎯 次のステップ

### 即座に実行可能
 1. **カスタムコンテンツ追加**
   ```bash
   # app/index.html を編集
   make app-deploy
   ```

 1. **監視設定**

- Azure Monitor設定
- アラート設定

### Phase3準備

 1. **GitHub認証設定**
 1. **CI/CD パイプライン構築**
 1. **自動デプロイ設定**

### 長期的改善

 1. **カスタムドメイン設定**
 1. **CDN追加**
 1. **AWS環境展開**
 1. **監視・ログ統合**
