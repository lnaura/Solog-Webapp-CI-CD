resource "kubernetes_namespace_v1" "sealed_secrets" {
  metadata {
    name = "sealed-secrets"
  }
}

resource "helm_release" "sealed_secrets" {
  name       = "sealed-secrets"
  repository = "https://bitnami-labs.github.io/sealed-secrets"
  chart      = "sealed-secrets"
  namespace  = kubernetes_namespace_v1.sealed_secrets.metadata[0].name
  version    = "2.15.0" 

  depends_on = [azurerm_kubernetes_cluster.aks]
}