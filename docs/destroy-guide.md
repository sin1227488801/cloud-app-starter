# 🗑️ リソース削除ガイド

## 概要

SRE IaC Starterで作成したAzureリソースを安全に削除するためのガイドです。

## 🎯 削除方法

### 1. ワンクリック削除（推奨）

```bash
# Makefileを使用した削除
make down-azure
```

**特徴:**
- 10秒の確認待機時間
- Terraformによる安全な削除
- フォールバック機能付き

### 2. GitHub Actions経由

1. **GitHub リポジトリにアクセス**
   - https://github.com/sin1227488801/sre-iac-starter

2. **Actions → terraform-destroy**
   - "Run workflow" をクリック

3. **確認入力**
   - `confirm_destroy` フィールドに `DESTROY` と入力
   - Environment: `azure-b1s-mvp` を選択

4. **実行**
   - "Run workflow" で削除開始

### 3. 手動スクリプト実行

```bash
# 詳細な削除スクリプト
bash scripts/destroy-azure.sh
```

**特徴:**
- 段階的な確認プロセス
- リソース一覧表示
- 手動フォールバック機能

## 🔍 削除されるリソース

### Azure リソース
- **Resource Group**: `sre-iac-starter-rg`
- **Storage Account**: `sreiacdev*` (ランダムサフィックス)
- **Virtual Network**: `sre-iac-starter-vnet`
- **Subnet**: `app`
- **Network Security Group**: 関連するNSG

### 削除順序
1. Storage Account内のBlob削除
2. Network関連リソース
3. Storage Account
4. Resource Group

## ⚠️ 注意事項

### 削除前の確認事項
- [ ] 重要なデータのバックアップ完了
- [ ] 他の環境への影響確認
- [ ] チームメンバーへの通知

### 削除できない場合
1. **手動削除**
   - Azure Portal から手動削除
   - Resource Group ごと削除が最も確実

2. **部分的な削除**
   ```bash
   # 特定のリソースのみ削除
   az resource delete --ids <resource-id>
   ```

3. **強制削除**
   ```bash
   # Resource Group の強制削除
   az group delete --name sre-iac-starter-rg --yes --no-wait
   ```

## 🛠️ トラブルシューティング

### よくある問題

#### 1. "Resource is locked" エラー
```bash
# ロックの確認と削除
az lock list --resource-group sre-iac-starter-rg
az lock delete --name <lock-name> --resource-group sre-iac-starter-rg
```

#### 2. "Storage account contains data" エラー
```bash
# Storage Account内のデータを手動削除
az storage blob delete-batch --account-name <storage-account> --source '$web'
```

#### 3. "Network interface in use" エラー
```bash
# VMが存在する場合は先にVM削除
az vm delete --resource-group sre-iac-starter-rg --name <vm-name>
```

### 削除状況の確認

```bash
# Resource Group の存在確認
az group show --name sre-iac-starter-rg

# リソース一覧確認
az resource list --resource-group sre-iac-starter-rg --output table

# 削除進行状況確認
az group wait --name sre-iac-starter-rg --deleted
```

## 📊 削除後の確認

### 1. Azure Portal確認
- Resource Group が削除されていることを確認
- 課金メーターが停止していることを確認

### 2. ローカル状態クリーンアップ
```bash
# Terraform状態ファイル削除
rm -f envs/azure/azure-b1s-mvp/terraform.tfstate*
rm -f envs/azure/azure-b1s-mvp/destroy.tfplan

# .terraformディレクトリ削除
rm -rf envs/azure/azure-b1s-mvp/.terraform
```

### 3. 課金確認
- Azure Cost Management で課金停止を確認
- 不要なリソースが残っていないかチェック

## 🔄 再デプロイ

削除後に再度デプロイする場合:

```bash
# 1. 状態クリーンアップ（上記参照）

# 2. 再デプロイ
make up-azure

# 3. アプリデプロイ
# GitHub Actions → app-deploy → Run workflow
```

## 📞 サポート

削除で問題が発生した場合:

1. **ログ確認**: GitHub Actions のログを確認
2. **手動削除**: Azure Portal から手動削除を試行
3. **Azure サポート**: 複雑な問題はAzureサポートに連絡

---

**⚠️ 重要**: 削除は不可逆的な操作です。実行前に必ず確認してください。