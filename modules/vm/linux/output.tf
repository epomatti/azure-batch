output "ssh_connect" {
  value = "ssh ${var.jumpbox_admin_user}@${azurerm_public_ip.main.ip_address}"
}
