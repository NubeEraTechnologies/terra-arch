output "web_lb_public_ip" {
  value = azurerm_public_ip.web_lb_pip.ip_address
}
