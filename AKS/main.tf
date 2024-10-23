# Zufällige Resource Group Namen Generierung
resource "random_pet" "rg_name" {
  prefix = var.resource_group_name_prefix
}

# Resource Group Definition
resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = random_pet.rg_name.id
  tags = {
    author = "Julian" # Von Azure Policy benötigt
    purpose = "Coding Challenge" # Von Azure Policy benötigt
  }
}

# Zufällige Kubernetes Cluster Namen und DNS-Präfix Generierung
resource "random_pet" "azurerm_kubernetes_cluster_name" {
  prefix = "cluster"
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

# Kubernetes Cluster Definition
resource "azurerm_kubernetes_cluster" "k8s" {
  location            = azurerm_resource_group.rg.location
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2s_v5" # Für die Erstellung des AKS in Northeurope benötigt.
    node_count = var.node_count
  }

# Konfiguriert das Netzwerkprofil des Clusters.
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
}

# Code, welcher benötigt wird, um Task 2 zu automatisieren.
/*resource "azurerm_kubernetes_cluster_node_pool" "np" {
  name                = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
  vm_size             = "Standard_D2s_v5"
  node_count          = 2
}

# ConfigMap to serve the HTML content
resource "kubernetes_config_map" "html_config" {
  metadata {
    name      = "html-config"
    namespace = "default"
  }

  data = {
    "index.html" = <<EOF
      <!DOCTYPE html>
      <html>
      <head>
        <title>Hello World</title>
      </head>
      <body>
        <h1>Hello World</h1>
      </body>
      </html>
    EOF
  }
}

# Deployment to create NGINX pods
resource "kubernetes_deployment" "hello_world" {
  metadata {
    name      = "hello-world"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "hello-world"
      }
    }
    template {
      metadata {
        labels = {
          app = "hello-world"
        }
      }
      spec {
        container {
          name  = "web"
          image = "nginx"
          port {
            container_port = 80
          }
          volume_mount {
            name       = "html"
            mount_path = "/usr/share/nginx/html"
          }
        }
        volume {
          name = "html"
          config_map {
            name = kubernetes_config_map.html_config.metadata[0].name
          }
        }
      }
    }
  }
}

# Service to expose NGINX deployment
resource "kubernetes_service" "hello_world_service" {
  metadata {
    name      = "hello-world-service"
    namespace = "default"
  }
  spec {
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
    selector = {
      app = "hello-world"
    }
  }
}*/
