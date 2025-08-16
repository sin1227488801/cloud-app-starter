# SRE IAC Starter (AWS) — ローカルで backend を作成 → 以降は GitHub Actions (OIDC)

このスターターは **「最短で安定」**を目的に、次の流れを前提にしています。

1. **ローカルで一度だけ** `backend-bootstrap` を実行して、Terraform の **S3 バケット**と **DynamoDB ロックテーブル**を作る
2. GitHub 側で **OIDC ロール**を用意（長期キー不要）
3. `.github/workflows/terraform-aws.yml` により、**Plan/Apply をGitHub Actionsで実行**

> 完全初心者でも進められるよう、以下の「手引書」に沿ってそのままコピペでOKです。

---

## 0. 前提

- AWS アカウントがあること
- リージョン: `ap-northeast-1`（変更可能）
- ローカル（WSL/Ubuntu など）に以下が入っていること
  - Terraform (>= 1.6)
  - AWS CLI v2

---

## 1. バックエンド（S3 + DynamoDB）をローカルで作成（1回だけ）

```bash
# 1) ローカル環境変数で一時クレデンシャルをセット（作成後に削除推奨）
export AWS_ACCESS_KEY_ID=AKIA...
export AWS_SECRET_ACCESS_KEY=...
export AWS_DEFAULT_REGION=ap-northeast-1

# 2) ディレクトリへ移動して apply
cd envs/aws/backend-bootstrap
terraform init
terraform apply -auto-approve
```

作成されるリソース：
- S3: `sre-iac-starter-tfstate`（バージョニング & SSE 有効、Public Block）
- DynamoDB: `sre-iac-starter-tf-lock`（ロックテーブル）

> 名前は `variables.tf` のデフォルトで生成されます。変更したい場合は apply 前に変数を編集してください。

---

## 2. GitHub OIDC ロールを AWS 側に作成

`iam/README.md` の手順に沿って、**信頼ポリシー（OIDC）**と**権限ポリシー**を設定し、
ロール `sre-iac-starter-oidc` を作成してください。

> 作成後、`terraform-aws.yml` の `role-to-assume` をその ARN に置き換えます。

---

## 3. GitHub Actions で Terraform を実行

1. 本リポジトリを GitHub にプッシュ
2. `.github/workflows/terraform-aws.yml` の `<ACCOUNT_ID>` と `<ROLE_NAME>` を置換
3. Actions タブからワークフローを実行

ワークフローは `envs/aws/stacks/vm-basic` を対象に以下を実行します：
- `terraform init`（S3 バックエンド）
- `fmt / validate / plan`
- `main ブランチへの push` のみ `apply`

---

## 4. 何がデプロイされる？

`vm-basic` スタックは、**デフォルト VPC のサブネット**に **Ubuntu インスタンス (t3.micro)** を 1 台作成し、
**cloud-init で Docker を自動導入**します。

出力：`vm_public_ip`（パブリックIP）  
確認：
```bash
ssh -i <your-key>.pem ubuntu@<vm_public_ip>
docker run hello-world
```

> デフォルト VPC が無い場合は、`variables.tf` で `vpc_id`/`subnet_id` を明示的に渡してください。

---

## 5. 代表コマンド（ローカルで動かしたい場合）

```bash
# backend の config を使って S3 バックエンドで init
cd envs/aws/stacks/vm-basic
terraform init -backend-config=../backend.hcl

# plan（必要に応じて VPC / Subnet を指定）
terraform plan   -var 'region=ap-northeast-1'   -var 'ssh_cidrs=["0.0.0.0/0"]'

# apply
terraform apply -auto-approve
```

---

## 6. 片付け

```bash
# 先に vm-basic を destroy
cd envs/aws/stacks/vm-basic
terraform destroy -auto-approve

# 次に backend-bootstrap を destroy（S3 の中身を空にしてから）
cd ../../backend-bootstrap
# バージョニングの削除 + オブジェクト削除は手動で実行する必要があります（注意）
terraform destroy -auto-approve
```

---

## トラブルシュート

- **`terraform init` で S3 バケットが無いと言われる**  
  → 1. の backend-bootstrap が未実施です。先に作成してください。

- **`No default VPC`**  
  → アカウントにデフォルト VPC が無い状態です。`variables.tf` で `vpc_id`/`subnet_id` を指定するか、
     別途 VPC を用意してから再実行してください。

- **`AccessDenied`（Actions で AssumeRole 失敗）**  
  → OIDC ロールの信頼ポリシーの `sub` パターン、`aud`、`repo` 名が合っているか確認してください（`iam/README.md` を参照）。
