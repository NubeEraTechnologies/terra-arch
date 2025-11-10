# Unique suffix so re-applies don't collide with earlier partial resources
resource "random_string" "sfx" {
  length  = 4
  lower   = true
  upper   = false
  special = false
}

# SSH key pair written locally (keep this file safe)
resource "tls_private_key" "vm_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_sensitive_file" "private_key" {
  filename = "webvm-key.pem"
  content  = tls_private_key.vm_key.private_key_pem
}

# Public IP for the VM
resource "azurerm_public_ip" "vm_pip" {
  name                = "pip-${var.project}-web-${random_string.sfx.result}"
  resource_group_name = data.terraform_remote_state.stage1.outputs.primary_rg
  location            = var.primary_location
  allocation_method   = "Static"
  sku                 = "Standard"
}

# NIC on the Stage-1 web subnet
resource "azurerm_network_interface" "vm_nic" {
  name                = "nic-${var.project}-web-${random_string.sfx.result}"
  resource_group_name = data.terraform_remote_state.stage1.outputs.primary_rg
  location            = var.primary_location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = data.terraform_remote_state.stage1.outputs.primary_web_subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip.id
  }
}

# One Ubuntu VM (22.04 LTS) with cloud-init to install NGINX
resource "azurerm_linux_virtual_machine" "web_vm" {
  name                = "vm-${var.project}-web-${random_string.sfx.result}"
  resource_group_name = data.terraform_remote_state.stage1.outputs.primary_rg
  location            = var.primary_location
  size                = "Standard_A2_v2"

  admin_username = var.vm_admin

  admin_ssh_key {
    username   = var.vm_admin
    public_key = tls_private_key.vm_key.public_key_openssh
  }

  network_interface_ids = [azurerm_network_interface.vm_nic.id]

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

  # Cloud-init: install nginx and show a simple page
  custom_data = base64encode(<<-CLOUDINIT
    #cloud-config
  package_update: true
  packages:
    - nginx
  runcmd:
    - systemctl enable nginx
    - systemctl start nginx
    - echo "<h1>It works - ${var.project} $(hostname)</h1>" > /var/www/html/index.nginx-debian.html
 CLOUDINIT
 )

}
