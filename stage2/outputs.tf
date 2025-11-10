output "resource_group" {
  value = data.terraform_remote_state.stage1.outputs.primary_rg
}

output "vm_public_ip" {
  value = azurerm_public_ip.vm_pip.ip_address
}

output "ssh_private_key" {
  value       = abspath(local_sensitive_file.private_key.filename)
  description = "Path to the generated PEM key"
  sensitive   = true
}

output "ssh_command" {
  value       = "ssh -i ${abspath(local_sensitive_file.private_key.filename)} ${var.vm_admin}@${azurerm_public_ip.vm_pip.ip_address}"
  description = "Convenience SSH command"
}
