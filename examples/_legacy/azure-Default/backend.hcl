# Fill AFTER bootstrapping storage
resource_group_name  = var.azure_state_rg
storage_account_name = var.azure_state_account
container_name       = var.azure_state_container
key                  = var.azure_state_key
