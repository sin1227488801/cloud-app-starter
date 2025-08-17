output "resource_group_name" {
  description = "Name of the Resource Group created by network module"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Location of the Resource Group created by network module"
  value       = azurerm_resource_group.rg.location
}
