terraform {
  required_providers {
    keycloak = {
      source = "mrparkers/keycloak"
      version = "3.9.0"
    }
  }
}

# provider "keycloak" {
#   client_id = "admin-cli"
#   username  = "admin"
#   password  = "admin"
#   url       = "http://keycloak.${var.namespace}.svc.cluster.local"
#   # url       = "http://localhost:8080"
#   realm     = "master"

#   # depends_on = [helm_release.keycloak]
# }