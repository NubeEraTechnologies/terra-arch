variable "project"              { default = "ha-dr" }
variable "primary_location"     { default = "eastus2" }
variable "primary_rg_name"      { type = string }
variable "primary_subnet_web_id" { type = string }
variable "vm_admin"             { default = "azureuser" }
