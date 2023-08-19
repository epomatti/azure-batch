### Workload ###
variable "sys" {
  type    = string
  default = "fastbrains"
}

variable "location" {
  type    = string
  default = "brazilsouth"
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

variable "provision_batch_private_links" {
  type    = bool
  default = false
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

variable "jumpbox_size_linux" {
  type    = string
  default = "Standard_B1ls"
}

variable "jumpbox_size_win" {
  type    = string
  default = "Standard_B2s"
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
