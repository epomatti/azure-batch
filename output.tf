output "linux_jumpbox" {
  value = "ssh ${var.jumpbox_admin_user}@${azurerm_public_ip.main.ip_address}"
}
