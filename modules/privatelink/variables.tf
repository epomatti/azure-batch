variable "sys" {
  type = string
}

variable "location" {
  type = string
}

variable "group" {
  type = string
}

variable "batch_account_id" {
  type = string
}

variable "vnet_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "provision_batchAccount_private_endpoint" {
  type = bool
}

variable "provision_nodeManagement_private_endpoint" {
  type = bool
}
