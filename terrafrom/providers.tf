provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "keycloak" {
    client_id = "admin-cli"
    username = var.keycloak_username
  
}