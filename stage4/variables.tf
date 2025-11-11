variable "project" {
  default = "ha-dr"
}

variable "tm_probe_protocol" {
  default = "HTTP"
}

variable "tm_probe_port" {
  default = 80
}

variable "tm_probe_path" {
  default = "/"
}

variable "dr_endpoint_fqdn" {
  type    = string
  default = ""
}
