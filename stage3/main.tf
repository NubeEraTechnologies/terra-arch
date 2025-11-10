# Unique suffix to avoid name collisions on re-applies
resource "random_string" "sfx" {
  length  = 4
  lower   = true
  upper   = false
  special = false
}

# Public IP for the Load Balancer
resource "azurerm_public_ip" "lb_pip" {
  name                = "pip-${var.project}-web-lb-${random_string.sfx.result}"
  resource_group_name = data.terraform_remote_state.stage1.outputs.primary_rg
  location            = var.primary_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Standard Load Balancer
resource "azurerm_lb" "web_lb" {
  name                = "lb-${var.project}-web-${random_string.sfx.result}"
  resource_group_name = data.terraform_remote_state.stage1.outputs.primary_rg
  location            = var.primary_location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "public-fe"
    public_ip_address_id = azurerm_public_ip.lb_pip.id
  }
}

resource "azurerm_lb_backend_address_pool" "web_pool" {
  name            = "web-bepool"
  loadbalancer_id = azurerm_lb.web_lb.id
}

resource "azurerm_lb_probe" "http" {
  name            = "http"
  loadbalancer_id = azurerm_lb.web_lb.id
  protocol        = "Tcp"
  port            = 80
}

resource "azurerm_lb_rule" "http_rule" {
  name                           = "http-80"
  loadbalancer_id                = azurerm_lb.web_lb.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "public-fe"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web_pool.id]
  probe_id                       = azurerm_lb_probe.http.id
}

# Two NICs (one per VM) attached to Stage-1 web subnet
resource "azurerm_network_interface" "web_nic" {
  count               = 1
  name                = "nic-${var.project}-web-${count.index}-${random_string.sfx.result}"
  resource_group_name = data.terraform_remote_state.stage1.outputs.primary_rg
  location            = var.primary_location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.terraform_remote_state.stage1.outputs.primary_web_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

# Associate NICs to LB backend pool
resource "azurerm_network_interface_backend_address_pool_association" "nic_to_pool" {
  count                   = 1
  network_interface_id    = azurerm_network_interface.web_nic[count.index].id
  ip_configuration_name   = "primary"
  backend_address_pool_id = azurerm_lb_backend_address_pool.web_pool.id
}

# Cloud-init for NGINX (safe heredoc)
locals {
  cloud_init = <<-CLOUDINIT
    #cloud-config
    package_update: true
    packages:
      - nginx
    runcmd:
      - systemctl enable nginx
      - systemctl start nginx
      - bash -lc 'echo "<h1>${var.project} - $(hostname)</h1>" > /var/www/html/index.nginx-debian.html'
  CLOUDINIT
}

# Two Ubuntu 22.04 VMs, spread across zones 1 and 2 (where available)
resource "azurerm_linux_virtual_machine" "web_vm" {
  count               = 1
  name                = "vm-${var.project}-web-${count.index}-${random_string.sfx.result}"
  resource_group_name = data.terraform_remote_state.stage1.outputs.primary_rg
  location            = var.primary_location
  size                = var.vm_size
  zone                = tostring(count.index + 1) # "1" and "2" when zones exist; Azure ignores if not zonal

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

  custom_data = base64encode(local.cloud_init)
}

# One shared SSH key for both VMs (written locally in stage3 folder)
resource "tls_private_key" "vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  filename = "web-ha-key.pem"
  content  = tls_private_key.vm_key.private_key_pem
}
