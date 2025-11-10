resource "random_string" "suffix" {
  length  = 5
  lower   = true
  upper   = false
  special = false
}

# Resource Group
resource "azurerm_resource_group" "primary" {
  name     = "rg-${var.project}-primary-${random_string.suffix.result}"
  location = var.primary_location
}

# VNet + Subnet
resource "azurerm_virtual_network" "primary" {
  name                = "vnet-${var.project}-primary"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name
  address_space       = [var.primary_vnet_cidr]
}

resource "azurerm_subnet" "primary_web" {
  name                 = "snet-web"
  resource_group_name  = azurerm_resource_group.primary.name
  virtual_network_name = azurerm_virtual_network.primary.name
  address_prefixes     = [var.subnets.web]
}

# NSG (allow SSH + HTTP) and associate to subnet
resource "azurerm_network_security_group" "web" {
  name                = "nsg-web"
  location            = azurerm_resource_group.primary.location
  resource_group_name = azurerm_resource_group.primary.name

  security_rule {
    name                       = "Allow-SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Allow-HTTP"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "web_assoc" {
  subnet_id                 = azurerm_subnet.primary_web.id
  network_security_group_id = azurerm_network_security_group.web.id
}
