variable "sys" {
  type    = string
  default = "fastbrains"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "jumpbox_size" {
  type    = string
  default = "Standard_DS1_v2"
}

variable "jumpbox_admin_user" {
  type    = string
  default = "bastionadmin"
}

variable "jumpbox_admin_password" {
  type      = string
  default   = "P@ssw0rd.123"
  sensitive = true
}
