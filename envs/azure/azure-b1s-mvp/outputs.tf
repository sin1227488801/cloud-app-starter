output "subnet_id" {
  value = module.network.subnet_id
}

output "static_website_url" {
  description = "URL of the static website"
  value       = module.static_site.static_website_url
}

output "storage_account_name" {
  description = "Name of the storage account for static website"
  value       = module.static_site.storage_account_name
}
