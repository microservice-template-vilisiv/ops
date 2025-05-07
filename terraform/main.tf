# module "keycloak" {
#   source = "./module/keycloak"
# }

module "istio" {
  source = "./module/istio"
}

module "postgres" {
  source = "./module/postgresql"
}