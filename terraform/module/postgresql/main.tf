#-------------------------
# Postgres Main
#-------------------------
resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
  }
}

locals {
  # repository = "https://charts.bitnami.com/bitnami"
  repository = "oci://registry-1.docker.io/bitnamicharts"
  version   = "16.6.6"
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
  version = local.version
  namespace = kubernetes_namespace.database.metadata[0].name
  
  set {
    name = local.authDatabase
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
  version = local.version
  namespace = kubernetes_namespace.database.metadata[0].name
  
  set {
    name = local.authDatabase
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