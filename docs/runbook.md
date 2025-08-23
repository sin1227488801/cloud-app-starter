# Cloud App Starter - 運用ランブック

## 🚀 初期セットアップ

### 1. 環境準備

```bash
# リポジトリクローン
git clone <repo-url>
cd cloud-app-starter

# 環境変数設定
cp .env.example .env
# .envファイルを編集して認証情報を設定

# 依存関係チェック
./scripts/doctor.sh
```

### 2. 開発環境セットアップ

```bash
# pre-commitフック設定
pip install pre-commit
pre-commit install

# コード品質チェック
pre-commit run --all-files
```

## 📋 日常運用タスク

### Terraformコード品質管理

```bash
# フォーマット
make fmt

# 検証
make validate CLOUD=azure
make validate CLOUD=aws

# 手動品質チェック
terraform -chdir=envs/azure validate
terraform -chdir=envs/aws validate
```

### インフラストラクチャデプロイメント

```bash
# 1. 初期化
make docker-init CLOUD=azure

# 2. プラン確認
make docker-plan CLOUD=azure

# 3. 適用
make docker-apply CLOUD=azure

# 4. 削除（必要時）
make docker-destroy CLOUD=azure
```

## 🔧 トラブルシューティング

### ステート管理

```bash
# ローカルステート確認
ls -la envs/azure/.terraform/
ls -la envs/aws/.terraform/

# ステートドリフト検出
terraform -chdir=envs/azure plan -detailed-exitcode
# Exit code 2 = changes detected
```

### 認証エラー対応

```bash
# Azure認証確認
az account show
az account list --output table

# AWS認証確認
aws sts get-caller-identity
aws configure list
```

### Docker実行環境問題

```bash
# イメージ更新
docker pull hashicorp/terraform:1.9.5

# コンテナ内デバッグ
docker run --rm -it --env-file .env -v $(PWD):/workspace -w /workspace hashicorp/terraform:1.9.5 sh
```

## 🔐 シークレット管理

### 環境変数の安全な管理

- `.env`ファイルは絶対にコミットしない
- CI/CDではGitHub Secretsを使用
- 本番環境では専用のシークレット管理サービス利用を推奨

### ローテーション手順

1. 新しい認証情報を生成
2. `.env`ファイルを更新
3. CI/CD環境のシークレットを更新
4. 古い認証情報を無効化

## 📊 監視・アラート

### リソース監視

```bash
# Azure リソース確認
az resource list --resource-group <rg-name> --output table

# AWS リソース確認
aws ec2 describe-instances --query 'Reservations[].Instances[].[InstanceId,State.Name,Tags[?Key==`Name`].Value|[0]]' --output table
```

### コスト監視

- Azure Cost Management
- AWS Cost Explorer
- 予算アラート設定を推奨

## 🚨 緊急時対応

### 障害対応フロー

1. 影響範囲の特定
2. ロールバック判断
3. 緊急修正またはロールバック実行
4. 事後分析・改善

### ロールバック手順

```bash
# 前回の正常なステートに戻す
terraform -chdir=envs/azure state pull > backup.tfstate
terraform -chdir=envs/azure destroy -auto-approve
# 必要に応じて手動リソース削除
```

## 📝 変更管理

### プルリクエストフロー

1. ブランチ作成
2. 変更実装
3. `terraform plan`結果をPRコメントで確認
4. レビュー・承認
5. マージ後の自動デプロイ（将来実装予定）

### 本番デプロイ前チェックリスト

- [ ] `terraform plan`で変更内容確認
- [ ] 影響範囲の評価
- [ ] バックアップ取得
- [ ] ロールバック手順確認
- [ ] 監視体制確認
