output "primary_rg" {
  value = azurerm_resource_group.primary.name
}

output "primary_vnet" {
  value = azurerm_virtual_network.primary.name
}

# FIND subnet name dynamically (any subnet that contains "web")
# safer approach
output "primary_web_subnet_id" {
  value = azurerm_subnet.primary_web.id
}

output "primary_rg_location" {
  value = azurerm_resource_group.primary.location
}

