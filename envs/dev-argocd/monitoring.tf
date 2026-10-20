resource "helm_release" "kube_prometheus_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  namespace        = "monitoring"
  create_namespace = true
  version          = "61.3.0"
  timeout          = 900 # Keep this to prevent timeouts

  set {
    name  = "grafana.adminPassword"
    value = "admin"
  }
  set {
    name  = "grafana.resources.requests.memory"
    value = "128Mi"
  }

  set {
    name  = "prometheus.prometheusSpec.resources.requests.memory"
    value = "256Mi"
  }

  # 3. Enable Alertmanager
  set {
    name  = "alertmanager.enabled"
    value = "true"
  }
  set {
    name  = "alertmanager.alertmanagerSpec.resources.requests.memory"
    value = "64Mi"
  }

  # 4. Configure the Webhook Receiver
  values = [<<EOF
alertmanager:
  config:
    route:
      receiver: 'webhook'
      group_by: ['alertname']
      group_wait: 10s
      group_interval: 10s
      repeat_interval: 1h
    receivers:
      - name: 'webhook'
        webhook_configs:
          - url: 'https://webhook.site/6bbcb582-8cb1-43ea-9a14-581f9c12c1fc'
EOF
  ]
}
