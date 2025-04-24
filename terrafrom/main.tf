module "keycloak" {
  source = "./module/keycloak"

  namespace = var.infra-namespace
}

module "istio" {
  source = "./module/istio"
}