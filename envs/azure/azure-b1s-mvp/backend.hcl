# Phase1: Local state (current)
# Phase2: Uncomment and configure remote state

# resource_group_name  = "tfstate-rg"
# storage_account_name = "tfstatesa"
# container_name       = "tfstate"
# key                  = "azure-b1s-mvp.tfstate"

# TODO Phase2: 
# 1. Create Azure Storage Account for state
# 2. Uncomment backend "azurerm" {} in main.tf
# 3. Run: terraform init -migrate-state -backend-config=backend.hcl
