#----------------------------------------------
# gateway config
#----------------------------------------------
resource "null_resource" "wait_for_gateway_crd" {
  provisioner "local-exec" {
    command = <<EOT
      for i in {1..30}; do
        kubectl get crd gateways.networking.istio.io && exit 0
        echo "Waiting for Gateway CRD..."
        sleep 5
      done
      echo "Timed out waiting for Gateway CRD" >&2
      exit 1
    EOT
  }

  depends_on = [helm_release.istio-ingress]
}

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
  
  depends_on = [ null_resource.wait_for_gateway_crd ]
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

  depends_on = [ null_resource.wait_for_gateway_crd ]
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

  depends_on = [ null_resource.wait_for_gateway_crd ]
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
  
  depends_on = [ null_resource.wait_for_gateway_crd ]
}