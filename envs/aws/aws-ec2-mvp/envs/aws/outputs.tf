output "public_ip" { value = module.compute.public_ip }
output "ssh_command" {
  value       = "ssh -o StrictHostKeyChecking=no ${module.compute.ssh_user}@${module.compute.public_ip}"
  description = "接続例（IP割当後）"
}
