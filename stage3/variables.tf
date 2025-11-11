variable "project"          { default = "ha-dr" }
variable "primary_location" { default = "eastus2" } # matches the stable region we used
variable "vm_admin"         { default = "azureuser" }
variable "vm_size" {
  type    = string
  default = "Standard_B1ms"
}

variable "primary_rg_name" {
  description = "primary resource group name from stage1"
  type        = string
}

