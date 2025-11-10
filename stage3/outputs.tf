output "lb_public_ip" {
  value       = azurerm_public_ip.lb_pip.ip_address
  description = "Public IP of the Load Balancer"
}

output "ssh_key_path" {
  value       = abspath(local_sensitive_file.private_key.filename)
  description = "Path to the generated PEM key"
  sensitive   = true
}

output "ssh_commands" {
  value = [
    "ssh -i ${abspath(local_sensitive_file.private_key.filename)} ${var.vm_admin}@${azurerm_public_ip.lb_pip.ip_address}",
    "curl http://${azurerm_public_ip.lb_pip.ip_address}"
  ]
}
