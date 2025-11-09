output "primary_rg" {
  value = azurerm_resource_group.primary.name
}

output "primary_web_subnet_id" {
  value = azurerm_subnet.primary_web.id
}
