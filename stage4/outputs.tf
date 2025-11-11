output "traffic_manager_dns" {
  value = "${azurerm_traffic_manager_profile.tm.dns_config[0].relative_name}.trafficmanager.net"
}

output "primary_endpoint_target" {
  value = data.terraform_remote_state.stage3.outputs.lb_public_ip
}
