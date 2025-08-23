# SRE IaC Starter

Azure/AWSマルチクラウド対応のTerraform IaCスターターキット

## 🎯 現在の状況

✅ **完了済み**
- Terraformモジュール構成（network, compute, static-website）
- GitHub Actions CI/CDパイプライン
- Azure Static Website自動デプロイ
- リモートステート管理（Azure Storage）

🔧 **修正済み**
- Terraformバックエンド設定の有効化
- ワークフローのoutput取得処理の簡素化
- デプロイ用HTMLファイルの作成

## 🚀 次のステップ

### 1. GitHubシークレットの設定確認

```bash
# シークレット確認
bash scripts/check-secrets.sh
```

必要なシークレット:
- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET` 
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

### 2. 手動でのTerraform状態確認

```bash
# 既存リソースのインポート確認
bash scripts/manual-import.sh
```

### 3. GitHub Actionsの実行

1. `terraform-apply` ワークフローを実行
2. `app-deploy` ワークフローを実行

## 📁 プロジェクト構成

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

**🎯 デモサイト**: [https://sreiacdevohgqvfjy.z11.web.core.windows.net/](https://sreiacdevohgqvfjy.z11.web.core.windows.net/)
