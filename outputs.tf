output "primary_rg" {
  description = "Primary Resource Group name"
  value       = azurerm_resource_group.primary.name
}

output "primary_vnet_id" {
  description = "Primary VNet ID"
  value       = azurerm_virtual_network.primary.id
}

output "primary_web_subnet_id" {
  description = "Web Subnet ID"
  value       = azurerm_subnet.primary_web.id
}
