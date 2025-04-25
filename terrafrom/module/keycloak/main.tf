#-------------------------
# Keycloak Main
#-------------------------

locals {
  keycloak_charts_url = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "keycloak" {
  repository = local.keycloak_charts_url
  chart     = "keycloak"
  name      = "keycloak"
  namespace = var.namespace

  values = [file("${path.module}/values.yaml")]

}

resource "keycloak_realm" "apprealm" {
  realm      = "apprealm"
  enabled    = true
  depends_on = [ helm_release.keycloak ]
}