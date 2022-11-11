output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "public_ip_address_kubemaster" {
  value = azurerm_linux_virtual_machine.my_k8s_vm_kubemaster.public_ip_address
}

output "public_ip_address_kubeworker" {
  value = azurerm_linux_virtual_machine.my_k8s_vm_kubeworker.public_ip_address
}

output "tls_private_key" {
  value     = tls_private_key.k8s_ssh.private_key_pem
  sensitive = true
}
