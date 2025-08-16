# SRE IAC Starter (Azure) — ローカルで backend を作成 → 以降は GitHub Actions (OIDC)

目的：**「初心者でも“手引書どおりに進めるだけ”で、Azure上にDocker入りVMをTerraformで作る」**。  
運用は **GitHub Actions + OIDC（長期キー不要）** に寄せています。

---

## 全体の流れ（最短ルート）

1. **ローカル**で一度だけ `backend-bootstrap` を適用して、Terraformの **State保管先(Storage Account + コンテナ)** を作る  
2. Azure で **アプリ登録 + Federated Credential(OIDC)** を作成し、対象のリソースグループに**権限(Contributor)**を付与  
3. リポジトリをGitHubにプッシュ → **GitHub Actions** が `init/fmt/validate/plan/apply` を実行

> 以降は **GitHub側のPlan/Applyで運用**できます。ローカルの長期資格情報は不要。

---

## 0. 前提

- Azureサブスクリプションを1つお持ちであること
- ローカル（WSL/Ubuntuなど）に以下が入っていること
  - Terraform (>= 1.6)
  - Azure CLI (`az login --use-device-code` が使える状態)

---

## 1. backend（Storage + Container）をローカルで作成（1回だけ）

```bash
# A) ログイン（WSLなどブラウザ無し環境はデバイスコード）
az login --use-device-code

# B) サブスクリプション選択（必要なら）
az account set --subscription "<SUBSCRIPTION_ID>"

# C) backend-bootstrap を適用
cd envs/azure/backend-bootstrap
terraform init
terraform apply -auto-approve
```

作成されるリソース（デフォルト値）
- リソースグループ: `sre-iac-rg-backend`
- ストレージアカウント: 例 `sreiactfstate<ランダム>`
- Blobコンテナ: `tfstate`

> 名前は `variables.tf` のデフォルトで作られます。変更したい場合は apply 前に編集してください。

---

## 2. GitHub OIDC（Entra IDのアプリ登録）を作成

`iam/README.md` の手順に沿って、以下を実施します：  
- アプリ登録（アプリケーションID = **Client ID** を取得）  
- **Federated Credential** を2つ（`main`、`pull_request`）作成  
- 対象リソースグループ（例：`sre-iac-rg`）に対して、アプリの**サービスプリンシパル**へ **ロール割り当て(Contributor)**  
- **Tenant ID / Subscription ID / Client ID** を控える

> これでActions内の `azure/login@v2` がOIDCでサインインできます。

---

## 3. GitHub Actions で Terraform を実行

1) リポジトリをGitHubへプッシュ  
2) `.github/workflows/terraform-azure.yml` の3つを置換：  
   - `AZURE_CLIENT_ID: "<CLIENT_ID>"`  
   - `AZURE_TENANT_ID: "<TENANT_ID>"`  
   - `AZURE_SUBSCRIPTION_ID: "<SUBSCRIPTION_ID>"`  
3) Actionsタブからワークフローを実行

このワークフローは `envs/azure/stacks/vm-basic` を対象に：  
- `terraform init`（azurerm backend）  
- `fmt / validate / plan`  
- `mainブランチへのpushのみ apply`

---

## 4. 何がデプロイされる？（vm-basic）

- リソースグループ（例：`sre-iac-rg`）
- VNet/Subnet/NSG（22, 80許可）
- Public IP + NIC
- Ubuntu 22.04 LTS の Linux VM（`Standard_B1s`）
- cloud-init で **Docker** を自動導入（`docker run hello-world` 試運転）

出力：`vm_public_ip`（パブリックIP）  
確認：
```bash
ssh -i <your-key>.pem azureuser@<vm_public_ip>
docker run hello-world
```

> SSH鍵はローカルの公開鍵を `~/.ssh/id_rsa.pub` などから読み込む想定です。`variables.tf` を参照。

---

## 5. ローカルで動かす場合の代表コマンド

```bash
# backendのconfigを渡してinit
cd envs/azure/stacks/vm-basic
terraform init -backend-config=../backend.hcl

# plan（必要に応じて変数調整）
terraform plan -var 'location=japaneast' -var 'ssh_allow_cidrs=["0.0.0.0/0"]'

# apply
terraform apply -auto-approve
```

---

## 6. 片付け

```bash
# 先に vm-basic を destroy
cd envs/azure/stacks/vm-basic
terraform destroy -auto-approve

# 次に backend-bootstrap を destroy
cd ../../backend-bootstrap
terraform destroy -auto-approve
```

---

## トラブルシュート

- **`terraform init` で backend が見つからない**  
  → 1 の backend-bootstrap が未実施です。実施後に `backend.hcl` の名前が一致しているか確認。

- **Actionsで `login` は通るが `plan` が権限不足**  
  → アプリの **サービスプリンシパル** に対し、対象RGに**Contributor**が割り当たっているかを確認。

- **SSHが繋がらない**  
  → NSGの22番が許可されているか、`ssh_allow_cidrs` を自宅IPに絞っている場合はIPの再確認。
