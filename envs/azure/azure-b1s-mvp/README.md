# Azure B1s MVP (Terraform + Docker)
- 最小コストの Ubuntu 22.04 / Standard_B1s を Terraform で作成→破棄
- `envs/azure` がルート、`modules/*` が再利用モジュール

## Quickstart
1) `.env.example` を `.env` にコピーして ARM_* を設定
2) Azure ログイン（WSLの場合は `--use-device-code` 推奨）
   ```bash
   az login --use-device-code
   ```
3) 実行
   ```bash
   make docker-init CLOUD=azure
   make docker-apply CLOUD=azure
   terraform -chdir=envs/azure output
   # 使い終わったら
   make docker-destroy CLOUD=azure
   ```
