#----------------------------------------------
#istio config
#----------------------------------------------
locals {
  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"
  istio_version = "1.24.5"
}

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