#-------------------------
# Keycloak Main
#-------------------------

locals {
  keycloak_charts_url = "https://charts.bitnami.com/bitnami"
}

resource "helm_release" "keycloak" {
  repository = local.keycloak_charts_url
  chart = "keycloak"
  name = "keycloak"
  namespace = var.namespace

  values = [file("values.yaml")]

}