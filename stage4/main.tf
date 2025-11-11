resource "azurerm_traffic_manager_profile" "tm" {
  name                = "tm-ha-dr"
  resource_group_name = data.terraform_remote_state.stage1.outputs.primary_rg
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "ha-dr-traffic-manager-demo"
    ttl           = 30
  }

  monitor_config {
    protocol = "HTTP"
    port     = 80
    path     = "/"
  }
}

resource "azurerm_traffic_manager_external_endpoint" "primary" {
  name       = "primary-endpoint"
  target     = data.terraform_remote_state.stage2.outputs.primary_lb_public_ip
  priority   = 1
  profile_id = azurerm_traffic_manager_profile.tm.id
}

resource "azurerm_traffic_manager_external_endpoint" "dr" {
  name       = "dr-endpoint"
  target     = data.terraform_remote_state.stage3.outputs.dr_lb_public_ip
  priority   = 2
  profile_id = azurerm_traffic_manager_profile.tm.id
}

output "traffic_manager_fqdn" {
  value = azurerm_traffic_manager_profile.tm.fqdn
}
