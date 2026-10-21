resource "helm_release" "nginx_ingress" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.10.1"

  # Bind the Nginx LoadBalancer to your specific Static IP
  set {
    name  = "controller.service.loadBalancerIP"
    value = "34.9.98.32" 
  }
}
