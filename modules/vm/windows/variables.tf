variable "sys" {
  type = string
}

variable "location" {
  type = string
}

variable "group" {
  type = string
}

variable "jumpbox_subnet" {
  type = string
}

variable "jumpbox_size" {
  type = string
}

variable "jumpbox_admin_user" {
  type = string
}

variable "jumpbox_admin_password" {
  type      = string
  sensitive = true
}
