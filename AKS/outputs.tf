# Outputs
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

# Gibt das Client-Zertifikat aus der Kubeconfig des Clusters aus.
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
  sensitive = true
}

# Gibt den Client-Schlüssel aus der Kubeconfig des Clusters aus.
output "client_key" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
  sensitive = true
}

# Gibt das CA-Zertifikat des Clusters aus der Kubeconfig aus.
output "cluster_ca_certificate" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
  sensitive = true
}

# Gibt das Passwort für den Zugriff auf den Cluster aus.
output "cluster_password" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].password
  sensitive = true
}

# Gibt den Benutzernamen für den Zugriff auf den Cluster aus.
output "cluster_username" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].username
  sensitive = true
}

# Gibt die Host-URL des Clusters aus.
output "host" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive = true
}

# Gibt die gesamte Kubeconfig als Rohdaten aus.
output "kube_config" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config_raw
  sensitive = true
}
