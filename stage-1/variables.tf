variable "project" { default = "ha-dr" }

variable "primary_location" { default = "eastus2" }
variable "dr_location"      { default = "centralus" }

variable "primary_vnet_cidr" { default = "10.0.0.0/16" }
variable "dr_vnet_cidr"      { default = "10.1.0.0/16" }

variable "subnets" {
  default = {
    web = "10.0.1.0/24"
    app = "10.0.2.0/24"
    db  = "10.0.3.0/24"
  }
}

variable "subnets_dr" {
  default = {
    web = "10.1.1.0/24"
    app = "10.1.2.0/24"
    db  = "10.1.3.0/24"
  }
}
