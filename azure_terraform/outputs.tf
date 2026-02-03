output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "connect_command" {
  value = "az aks get-credentials --resource-group ${azurerm_resource_group.solog.name} --name ${azurerm_kubernetes_cluster.aks.name}"
}