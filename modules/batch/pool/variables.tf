variable "sys" {
  type = string
}

variable "location" {
  type = string
}

variable "group" {
  type = string
}

variable "storage_jobfiles_id" {
  type = string
}

variable "jobfiles_storage_name" {
  type = string
}

variable "batch_account_name" {
  type = string
}

variable "batch_vm_size" {
  type = string
}

variable "batch_subnet_id" {
  type = string
}

variable "public_address_provisioning_type" {
  type = string
}

variable "jobfiles_storage_account_key" {
  type      = string
  sensitive = true
}

variable "share_url" {
  type = string
}
