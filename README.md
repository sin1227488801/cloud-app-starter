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


# SRE IaC Starter (Terraform + Docker, Azure & AWS)

Minimal, reproducible IaC scaffold to deploy the same small stack on **Azure** and **AWS**.
Goal: anyone can run the same commands and get the same infra.

## Quickstart
1) Copy env file and edit minimal vars:
   ```bash
   cp .env.example .env
   ```
2) Try Azure first (local state is fine initially):
   ```bash
   make docker-init CLOUD=azure
   make docker-plan CLOUD=azure
   make docker-apply CLOUD=azure
   # verify, then
   make docker-destroy CLOUD=azure
   ```
3) Then AWS:
   ```bash
   make docker-init CLOUD=aws
   make docker-plan CLOUD=aws
   make docker-apply CLOUD=aws
   make docker-destroy CLOUD=aws
   ```

## Layout
- `envs/<cloud>`: root modules & backend config
- `modules/*`: reusable pieces (keep small)
- `docker/terraform`: pinned Terraform runner
- `scripts/*`: helpers
- `.github/workflows`: optional CI validate
- `docs/`: runbook, diagrams

## Notes
- Start with **LOCAL state** → switch to remote later.
- Keep modules tiny: `network`, `compute` first; add `observability` later.
- Use Docker runner to avoid local TF/version drift.
