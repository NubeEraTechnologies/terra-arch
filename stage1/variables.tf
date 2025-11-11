variable "project" {
  description = "Short name used in resource names"
  type        = string
  default     = "ha-dr"
}

variable "primary_location" {
  description = "Azure region"
  type        = string
  default     = "eastus2"
}

variable "primary_vnet_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "subnets" {
  description = "Subnet CIDRs"
  type = object({
    web = string
  })
  default = {
    web = "10.0.1.0/24"
  }
}

