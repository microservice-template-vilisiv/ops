locals {
  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"
  istio_version = "1.24.5"
}

#----------------------------------------------
#istio config
#----------------------------------------------

resource "helm_release" "istio-base" {
  repository       = local.istio_charts_url
  chart            = "base"
  name             = "istio-base"
  namespace        = var.namespace
  version          = local.istio_version
  create_namespace = true
}

resource "helm_release" "istiod" {
  repository       = local.istio_charts_url
  chart            = "istiod"
  name             = "istiod"
  namespace        = var.namespace
  create_namespace = true
  version          = local.istio_version
  depends_on       = [helm_release.istio-base]
}

resource "kubernetes_namespace" "istio-ingress" {
  metadata {
    labels = {
      istio-injection = "enabled"
    }

    name = "istio-ingress"
  }
}

resource "helm_release" "istio-ingress" {
  repository = local.istio_charts_url
  chart      = "gateway"
  name       = "istio-ingress"
  namespace  = kubernetes_namespace.istio-ingress.metadata[0].name
  version    = local.istio_version
  depends_on = [helm_release.istiod]
}


#----------------------------------------------
# gateway config
#----------------------------------------------
resource "kubernetes_manifest" "gateway" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "Gateway"
    metadata   = {
      name       = "api-gateway"
      namespace  = "istio-ingress"
    }
    spec = {
      selector = {
        istio = "ingressgateway"
      }
      servers = [
        {
          port = {
            number   = 80
            name     = "http"
            protocol = "HTTP"
          }
          hosts = ["*"]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "virtual_service" {
  manifest = {
    apiVersion = "networking.istio.io/v1beta1"
    kind       = "VirtualService"
    metadata   = {
      name       = "api-virtual-service"
      namespace  = "istio-ingress"
    }
    spec = {
      hosts    = ["*"]
      gateways = ["api-gateway"]
      http     = [
        {
          match = [{ uri = { prefix = "/test" } }],
          route = [{ destination = { host = "api-service.default.svc.cluster.local", port = { number = 80 } }}]
        },
        {
          match = [{ uri = { prefix = "/auth" } }],
          route = [{ destination = { host = "auth-service.default.svc.cluster.local", port = { number = 80 } }}]
        }
      ]
    }
  }
}


#----------------------------------------------
# auth config
#----------------------------------------------
resource "kubernetes_manifest" "jwt_auth" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "RequestAuthentication"
    metadata   = {
      name       = "jwt-auth"
      namespace  = "istio-ingress"
    }
    spec = {
      selector = {
        matchLabels = {
          istio = "ingressgateway"
        }
      }
      jwtRules = [
        {
          # @todo: edit realms name with actual running realms
          issuer = "http://keycloak.${var.keycloak-namespace}.svc.cluster.local/realms/${var.keycloak-realm}"
          jwksUri = "http://keycloak.${var.keycloak-namespace}.svc.cluster.local/realms/${var.keycloak-realm}/protocol/openid-connect/certs"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "auth_policy" {
  manifest = {
    apiVersion = "security.istio.io/v1beta1"
    kind       = "AuthorizationPolicy"
    metadata   = {
      name       = "require-jwt"
      namespace  = "istio-ingress"
    }
    spec = {
      selector = {
        matchLabels = {
          istio = "ingressgateway"
        }
      }
      action = "ALLOW"
      rules  = [
        {
          from  = [{ source    = { requestPrincipals = ["*"]} }]
          to    = [{ operation = { notPaths = ["/auth/login", "/auth/register"] }
          }]
        },
        {
          to    = [{ operation = { paths = ["/auth/login", "/auth/register"]}}] 
        }
      ]
    }
  }
  
}