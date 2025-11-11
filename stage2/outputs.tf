# Public IP attached to the Stage-2 VM NIC
output "vm_public_ip" {
  value       = azurerm_public_ip.vm_pip.ip_address
  description = "Public IPv4 of the Stage-2 VM"
}

output "vm_public_ip_id" {
  value       = azurerm_public_ip.vm_pip.id
  description = "Resource ID of the Stage-2 VM Public IP"
}
