#-------------------------
# Postgres Main
#-------------------------

locals {
  repository = "https://charts.bitnami.com/bitnami"
  namespace = "database"

  authPostgresPassword = "auth.postgresPassword"
  authUsername  = "auth.username"
  authPassword  = "auth.password"
  authDatabase  = "auth.database"
  primaryPersistenceEnable = "primary.persistence.enabled"
  primaryPersistenceSize   = "primary.persistence.size"
}

resource "helm_release" "postgres_keycloak" {
  name = "postgres-keycloak"
  repository = local.repository
  chart = "postgresql"
  namespace = local.namespace
  
  set {
    name = locals.database
    value = "keycloak_db"
  }

  set {
    name = local.authPostgresPassword
    value = "KC_ROOT_PW"
  }

  set {
    name = local.authUsername
    value = "KC_USERNAME"
  }

  set {
    name = local.authPassword
    value = "KC_PW"
  }

  set {
    name = local.primaryPersistenceEnable
    value = "true"
  }

  set {
    name = local.primaryPersistenceSize
    value = "1Gi"
  }
}


resource "helm_release" "postgres_app" {
  name = "postgres-app"
  repository = local.repository
  chart = "postgresql"
  namespace = local.namespace
  
  set {
    name = locals.database
    value = "app_db"
  }

  set {
    name = local.authPostgresPassword
    value = "APP_ROOT_PW"
  }
  
  set {
    name = local.authUsername
    value = "APP_USERNAME"
  }

  set {
    name = local.authPassword
    value = "APP_PW"
  }

  set {
    name = local.primaryPersistenceEnable
    value = "true"
  }

  set {
    name = local.primaryPersistenceSize
    value = "1Gi"
  }
}