# Network access
batch_account_public           = true
network_account_access         = "Allow"
network_node_management_access = "Allow"

# Private Link
provision_private_link                    = false
provision_batchAccount_private_endpoint   = false
provision_nodeManagement_private_endpoint = false

# Batch Pool
provision_batch_pool = false
batch_vm_size        = "STANDARD_D2S_V3" # "Standard_D2ads_v5"

# Virtual Machines
provision_linux_vm = false
provision_win_vm   = false

jumpbox_linux_vm_size = "Standard_B2pts_v2"
jumpbox_win_vm_size   = "Standard_B4as_v2"
