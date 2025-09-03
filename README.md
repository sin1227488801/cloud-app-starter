# 🚀 Cloud App Starter - ワンクリックWebサイト作成ツール

**初心者でもOK！** ブラウザだけで美しいWebサイトを5分で作成・公開できます。

## ✨ 何ができる？

- 🌐 **Webサイト作成**: サイトを自動生成
- ⚡ **5分で公開**: 面倒な設定不要、数クリックで世界に公開
- 💰 **ほぼ無料**: 月数円程度、使わない時は削除で完全無料
- 🗑️ **簡単削除**: 不要になったら数クリックで削除

## 🎯 デモサイト

**実際に作成されるサイト**: <https://cloudadevypglfxby.z11.web.core.windows.net/>

## 🚀 今すぐ始める

| 対象者 | ガイド | 所要時間 | 内容 |
|--------|--------|----------|------|
| 🔰 **完全初心者** | **[📚 完全ガイド](docs/beginner-guide.md)** | 30分 | アカウント作成から詳細解説 |
| ⚡ **経験者** | **[🚀 クイックスタート](docs/quick-start.md)** | 5分 | 最速でサイト公開 |
| 📱 **今すぐ試したい** | **[⚡ QUICKSTART](QUICKSTART.md)** | 1分 | 超簡潔な手順 |
| 🔧 **開発者** | **👇 技術詳細** | - | アーキテクチャと設定 |

---

## 🎯 技術詳細（開発者向け）

### ✅ 実装済み機能

- **Infrastructure as Code**: Terraformによる自動化
- **CI/CD Pipeline**: GitHub Actionsによる自動デプロイ
- **Multi-Cloud対応**: Azure対応
- **セキュリティ**: Service Principal認証
- **モニタリング**: リアルタイム状況表示
- **ワンクリック削除**: 安全な削除システム

### 🏗️ アーキテクチャ

```
GitHub → Actions → Terraform → Azure Storage → Static Website
   ↓        ↓         ↓            ↓              ↓
コード変更 → 自動検知 → インフラ更新 → ファイル配置 → サイト公開
```

### 🛠️ 開発者向けローカル環境

#### Linux/Mac (Make使用)

```bash
# 1. リポジトリクローン
git clone https://github.com/sin1227488801/cloud-app-starter.git
cd cloud-app-starter

# 2. 認証情報設定
cp .env.example .env
# .envファイルを編集して実際の認証情報を設定

# 3. ワンクリックデプロイ
make up-azure     # インフラ構築
make url-azure    # URL確認

# 4. ワンクリック削除
make down-azure   # 完全削除
```

#### Windows (PowerShell使用)

```powershell
# 1. リポジトリクローン
git clone https://github.com/sin1227488801/cloud-app-starter.git
cd cloud-app-starter

# 2. 認証情報設定
Copy-Item .env.example .env
# .envを編集して実際の認証情報を設定

# 3. ワンクリックデプロイ
.\azure-deploy.ps1 up        # インフラ構築
.\azure-deploy.ps1 url       # URL確認

# 4. ワンクリック削除
.\azure-deploy.ps1 down      # 完全削除
```

### 🎯 デモの見方

1. **ローカルデモ**: 上記手順でデプロイ後、`make url-azure`で表示されるURLにアクセス
2. **ライブデモ**: [https://cloudappdevm627ymaf.z11.web.core.windows.net/](https://cloudappdevm627ymaf.z11.web.core.windows.net/)
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

## 🗑️ リソース削除

### ワンクリック削除（ローカル）

#### Linux/Mac

```bash
# 5秒の確認待機後に削除実行
make down-azure

# または手動スクリプト実行
bash scripts/destroy-azure.sh
```

#### Windows

```powershell
# 5秒の確認待機後に削除実行
.\azure-deploy.ps1 down
```

### GitHub Actions経由での削除

1. GitHub Actions → terraform-destroy → Run workflow
2. 確認フィールドに「DESTROY」と入力
3. 実行して全リソースを削除

⚠️ **注意**: 削除は取り消せません。本番環境では十分注意してください。

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
