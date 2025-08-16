# GitHub OIDCでTerraformを動かすためのAzure側設定

## 1) アプリ登録（Entra ID）

1. Azure Portal → **Microsoft Entra ID** → **アプリの登録** → **新規登録**
2. 名前: `sre-iac-starter-gha`
3. 「この組織ディレクトリのみに含まれているアカウント」でも可（用途に応じ選択）
4. 登録後、**アプリケーション(クライアント)ID** を控える（= Client ID） dabb9519-bbc3-4638-988f-3a0dfdd09286
   併せて **ディレクトリ(テナント)ID** も控える（= Tenant ID）6b0d480e-acf2-4257-8520-64654f367dc8

## 2) Federated Credential を追加（2つ）

アプリ登録 → **証明書とシークレット** → **Federated credential** → **追加**
テンプレート: **GitHub Actions** を選択し、以下を作成：

- **mainブランチ**
  - Organization: `<OWNER>`
  - Repository: `<REPO>`
  - Entity type: `Branch`
  - GitHub reference: `refs/heads/main`

- **Pull Request**
  - Organization: `<OWNER>`
  - Repository: `<REPO>`
  - Entity type: `Pull request`
  - GitHub reference: `*`

> これで GitHub → Azure へのOIDCフェデレーションが確立します。

## 3) サービスプリンシパルへロール付与

1. 対象サブスクリプション または **対象リソースグループ（推奨）** を開く
2. **アクセス制御(IAM)** → **ロールの割り当ての追加**
3. ロール: `Contributor`（検証時はこれでOK。後で最小権限へ）
4. メンバー: 上記アプリの **サービスプリンシパル** を選択して割り当て

## 4) GitHub Secrets を設定

対象リポジトリ → **Settings** → **Secrets and variables** → **Actions** → **New repository secret**

- `AZURE_CLIENT_ID` = アプリの **アプリケーション(クライアント)ID**
- `AZURE_TENANT_ID` = **ディレクトリ(テナント)ID**
- `AZURE_SUBSCRIPTION_ID` = 対象サブスクリプションID

> ワークフロー `.github/workflows/terraform-azure.yml` は、これらのシークレットを使って `azure/login@v2` でログインします。
