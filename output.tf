output "linux_ssh_connect" {
  value = module.vm_linux[*].ssh_connect
}
