output "static_website_url" {
  description = "URL of the static website"
  value       = azurerm_storage_account.static_site.primary_web_endpoint
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.static_site.name
}

output "storage_account_id" {
  description = "ID of the storage account"
  value       = azurerm_storage_account.static_site.id
}
