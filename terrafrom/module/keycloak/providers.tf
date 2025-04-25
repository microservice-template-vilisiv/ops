terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = "3.9.0"
    }
  }
}

provider "keycloak" {
  client_id = "admin-cli"
  username  = "admin"
  password  = "admin"
  url       = "http://keycloak.${var.namespace}.svc.cluster.local"
  realm     = "master"
}