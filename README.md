# IaC MultiCloud Prototype (Terraform + Docker + Azure/AWS)

## 概要

このプロジェクトは、TerraformとDockerを活用してAzureとAWSの両方に同一構成をデプロイするプロトタイプです。
非エンジニアでも `docker run` 1コマンドで環境再現が可能です。

## 特徴

- **Terraformモジュール化**: ネットワーク・コンピュート・監視を分離し再利用性を確保
- **Docker実行環境**: ローカル環境依存を排除
- **マルチクラウド対応**: AzureとAWS両方に同一構成を適用可能
- **Remote State**: Azure Storage & Key Vault / S3 & DynamoDBでステート管理

## クイックスタート

1. `.env` に認証情報を設定
2. Dockerビルド

docker build -t iac-runner .
3. 実行（Azureの場合）

docker run --rm --env-file .env iac-runner terraform -chdir=terraform/azure apply
4. 実行（AWSの場合）

docker run --rm --env-file .env iac-runner terraform -chdir=terraform/aws apply

## 予定される利用シーン

- SREチームによるクラウド環境の統一管理
- 新規メンバーが1日で再現可能な検証環境構築
- クラウド間移行やDR（災害復旧）の基礎検証

markdown
コピーする
編集する

markdown
コピーする
編集する

## SRE IaC Starter (Terraform + Docker, Azure & AWS)

Minimal, reproducible IaC scaffold to deploy the same small stack on **Azure** and **AWS**.
Goal: anyone can run the same commands and get the same infra.

## 🚀 Quickstart

### 1分デプロイ

```bash
# 1. リポジトリクローン
git clone https://github.com/sin1227488801/sre-iac-starter.git
cd sre-iac-starter

# 2. 認証情報設定
cp .env.example .env
# .envを編集して実際の認証情報を設定

# 3. インフラ構築
make up-azure

# 4. アプリデプロイ
make app-deploy

# 5. URL確認
make url-azure
```

### 🎯 デモの見方

1. **ローカルデモ**: 上記手順でデプロイ後、`make url-azure`で表示されるURLにアクセス
2. **ライブデモ**: [https://sreiacdevm627ymaf.z11.web.core.windows.net/](https://sreiacdevm627ymaf.z11.web.core.windows.net/)
3. **UI機能**:
   - フェーズ進捗の可視化
   - リアルタイムデプロイ状況
   - ワンクリックコマンドコピー
   - アーキテクチャ図表示

### 🔄 CI/CD フロー

```text
Developer → git push → GitHub Actions → Terraform → Azure Storage → Static Website
     ↓              ↓                    ↓              ↓              ↓
   コード変更      PR作成時プラン      インフラ更新    アプリデプロイ   自動反映
```

## Layout

- `envs/<cloud>`: root modules & backend config
- `modules/*`: reusable pieces (keep small)
- `docker/terraform`: pinned Terraform runner
- `scripts/*`: helpers
- `.github/workflows`: optional CI validate
- `docs/`: runbook, diagrams

## Development Setup

### Pre-commit Hooks

コード品質を自動化するため、pre-commitフックを設定してください：

```bash
# pre-commitのインストール
pip install pre-commit

# フックの設定
pre-commit install

# 手動実行（全ファイル）
pre-commit run --all-files
```

## Notes

- Start with **LOCAL state** → switch to remote later.
- Keep modules tiny: `network`, `compute` first; add `observability` later.
- Use Docker runner to avoid local TF/version drift.

## 🔄 CI/CD パイプライン

### 自動化フロー

1. **PR作成時**: `terraform-plan-pr` ワークフローが実行
   - Azure/AWS環境のプラン結果をPRにコメント
   - 構文チェック・検証実行

2. **mainマージ時**:
   - `terraform-apply`: インフラ変更を自動適用
   - `app-deploy`: アプリファイル変更を自動デプロイ

3. **リアルタイム更新**:
   - `meta.json`でデプロイ状況を追跡
   - ウェブサイトで最新状況を表示

### ワークフロー詳細

- **terraform-plan-pr.yaml**: PR時の自動プラン
- **terraform-apply.yaml**: インフラ自動適用
- **app-deploy.yaml**: 静的サイト自動デプロイ

### 将来の拡張予定

- **Remote State**: Azure Storage Backend移行
- **Security**: tfsec/checkov統合
- **Testing**: Terratest導入
- **Environments**: staging/production分離

**🎯 デモサイト**: [https://sreiacdevm627ymaf.z11.web.core.windows.net/](https://sreiacdevm627ymaf.z11.web.core.windows.net/)
