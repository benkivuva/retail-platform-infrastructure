resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno"
  chart            = "kyverno"
  namespace        = "kyverno"
  create_namespace = true
  version          = "3.2.6"

  # Keep resource requests small for our dev cluster
  set {
    name  = "admissionController.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "backgroundController.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "cleanupController.resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "reportsController.resources.requests.memory"
    value = "128Mi"
  }
}
