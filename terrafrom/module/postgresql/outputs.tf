output "keycloak_db_host" {
  value = "postgres-keycloak-postgresql.default.svc.cluster.local"
}

output "app_db_host" {
  value = "postgres-app-postgresql.default.svc.cluster.local"
}