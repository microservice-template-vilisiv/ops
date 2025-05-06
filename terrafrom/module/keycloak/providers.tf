terraform {
  required_providers {
    keycloak = {
      source = "keycloak/keycloak"
      version = ">= 5.0.0"
    }
  }
}
provider "keycloak" {
  client_id = "terraform_user"
  client_secret = "psswd123"
  # url       = "http://keycloak.${var.namespace}.svc.cluster.local"
  url       = "http://192.168.49.2:8080"
  # url       = "http://localhost:8080"
  realm     = "master"

  # depends_on = [helm_release.keycloak]
}