resource "random_string" "suffix" {
  length  = 5
  lower   = true
  upper   = false
  special = false
}

resource "azurerm_resource_group" "primary" {
  name     = "rg-${var.project}-primary-${random_string.suffix.result}"
  location = var.primary_location
}

resource "azurerm_resource_group" "dr" {
  name     = "rg-${var.project}-dr-${random_string.suffix.result}"
  location = var.dr_location
}

resource "azurerm_virtual_network" "primary" {
  name                = "vnet-${var.project}-primary"
  resource_group_name = azurerm_resource_group.primary.name
  location            = azurerm_resource_group.primary.location
  address_space       = [var.primary_vnet_cidr]
}

resource "azurerm_subnet" "primary_web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = [var.subnets.web]
}
