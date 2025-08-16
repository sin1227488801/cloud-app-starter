terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"   # 3.29+ で対応、あなたの環境は 3.117 なのでOK
    }
  }
}

provider "azurerm" {
  features {
        virtual_machine {
      # 削除前の graceful shutdown をスキップして強制削除
      skip_shutdown_and_force_delete = true

      # ついでに OSディスクも自動削除したいなら有効化
      # delete_os_disk_on_deletion = true
    }
  }
  skip_provider_registration = true
}