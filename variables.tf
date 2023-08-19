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


### Jumpbox ###
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
