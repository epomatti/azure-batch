### Workload ###
variable "sys" {
  type    = string
  default = "fastbrains"
}

variable "location" {
  type    = string
  default = "eastus"
}

### Batch ###
variable "batch_vm_size" {
  type    = string
  default = "STANDARD_D2S_V3"
}

variable "batch_account_public" {
  type    = bool
  default = true
}

variable "provision_batch_pool" {
  type    = bool
  default = false
}

variable "public_address_provisioning_type" {
  type = string
}

### Network ###
variable "network_account_access" {
  type    = string
  default = "Allow"
}

variable "network_node_management_access" {
  type    = string
  default = "Allow"
}

### Private Endpoints ###
variable "provision_private_link" {
  type    = bool
  default = false
}

variable "provision_batchAccount_private_endpoint" {
  type    = bool
  default = false
}

variable "provision_nodeManagement_private_endpoint" {
  type    = bool
  default = true
}

### Jumpbox ###
variable "provision_linux_vm" {
  type    = bool
  default = false
}

variable "provision_win_vm" {
  type    = bool
  default = false
}

variable "jumpbox_linux_vm_size" {
  type = string
}

variable "jumpbox_win_vm_size" {
  type = string
}
