module "keycloak" {
  source = "./module/keycloak"
}

module "istio" {
  source = "./module/istio"
  keycloak-namespace = module.keycloak.keycloak-namespace
  keycloak-realm = module.keycloak.keycloak-realm
}