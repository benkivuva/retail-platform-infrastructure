resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "61.3.0"
  timeout          = 900 # Added to prevent timeout during the heavy CRD install

  set {
    name  = "grafana.adminPassword"
    value = "admin"
  }

  set {
    name  = "alertmanager.enabled"
    value = "false"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "256Mi"
  }

  set {
    name  = "grafana.resources.requests.memory"
    value = "128Mi"
  }
}
