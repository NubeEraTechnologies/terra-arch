resource "tls_private_key" "vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  filename = "privatekey.pem"
  content  = tls_private_key.vm_key.private_key_pem
}

resource "azurerm_public_ip" "web_lb_pip" {
  name                = "pip-${var.project}-web-lb"
  resource_group_name = var.primary_rg_name
  location            = var.primary_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "web_lb" {
  name                = "lb-${var.project}-web"
  resource_group_name = var.primary_rg_name
  location            = var.primary_location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-fe"
    public_ip_address_id = azurerm_public_ip.web_lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_pool" {
  name            = "web-bepool"
  loadbalancer_id = azurerm_lb.web_lb.id
}

resource "azurerm_lb_probe" "http_probe" {
  name            = "http"
  loadbalancer_id = azurerm_lb.web_lb.id
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_network_interface" "web_nic" {
  count               = 2
  name                = "nic-web-${count.index}"
  resource_group_name = var.primary_rg_name
  location            = var.primary_location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = var.primary_subnet_web_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_backend_address_pool_association" "web_nic_pool" {
  count                   = 2
  network_interface_id    = azurerm_network_interface.web_nic[count.index].id
  ip_configuration_name   = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_pool.id
}

resource "azurerm_linux_virtual_machine" "web_vm" {
  count               = 2
  name                = "vm-web-${count.index}"
  resource_group_name = var.primary_rg_name
  location            = var.primary_location
  size                = "Standard_DS1_v2"
  zone                = tostring(count.index + 1)

  admin_username = var.vm_admin

  admin_ssh_key {
    username   = var.vm_admin
    public_key = tls_private_key.vm_key.public_key_openssh
  }

  network_interface_ids = [azurerm_network_interface.web_nic[count.index].id]

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
