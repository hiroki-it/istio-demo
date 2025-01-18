# 8章

8章では、テレメトリーを監視します。

## セットアップ

1. Namespaceをデプロイします。

```bash
kubectl apply --server-side -f 08/shared/namespace.yaml
```

### PrometheusとGrafana

2. Prometheusのカスタムリソース定義をデプロイする。

```bash
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml
kubectl apply --server-side -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/v0.79.0/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml
```

3. Prometheusをデプロイする。

```bash
helmfile -f 08/prometheus/helmfile.yaml apply
```

4. Prometheusのダッシュボードに接続します。ブラウザからPodの`9090`番ポートに接続してください。

```bash
kubectl port-forward svc/prometheus-server -n istio-system 9090:9090
```

5. Grafanaをデプロイする。

```bash
helmfile -f 08/grafana/grafana/helmfile.yaml apply
```

6. Grafanaのダッシュボードに接続します。ブラウザからPodの`8000`番ポートに接続してください。

```bash
kubectl port-forward svc/grafana -n istio-system 8000:80
```

### Kiali

7. Kialiをデプロイします。

```bash
helmfile -f 08/kiali/helmfile.yaml apply
```

8. Kialiのダッシュボードに接続します。ブラウザからPodの`20001`番ポートに接続してください。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

### Minio

9. Minioをデプロイします。

```bash
helmfile -f 08/minio/helmfile.yaml apply
```

### Grafana Loki

10. Grafana Lokiをデプロイします。

```bash
helmfile -f 08/grafana/grafana-loki/helmfile.yaml apply
```

### Grafana Promtail

11. Grafana Promtailをデプロイします。

```bash
helmfile -f 08/grafana/grafana-promtail/helmfile.yaml apply
```

### Grafana Tempo

12. Grafana Tempoをデプロイします。

```bash
helmfile -f 08/grafana/grafana-tempo/helmfile.yaml apply
```

### OpenTelemetry Collector

13. OpenTelemetry Collectorをデプロイします。

```bash
helmfile -f 08/opentelemetry-collector/helmfile.yaml apply
```

14. OpenTelemetry CollectorのPodのログから、istio-proxyの送信したスパンを確認します。

```bash
kubectl logs <OpenTelemetry CollectorのPod> -n istio-system -f

Resource SchemaURL:
Resource attributes:
     -> service.name: Str(reviews.app)
     -> k8s.pod.ip: Str(127.0.0.6)
ScopeSpans #0
ScopeSpans SchemaURL:
InstrumentationScope
Span #0
    Trace ID       : e628c2e56566a155a4e60782861c39cf
    Parent ID      : b3b5bf6e9caa41f0
    ID             : 5adf8431816989f3
    Name           : ratings:9080/*
    Kind           : Client
    Start time     : 2025-01-13 11:54:43.953816 +0000 UTC
    End time       : 2025-01-13 11:54:43.967079 +0000 UTC
    Status code    : Unset
    Status message :
Attributes:
    ...
```

### Istio

15. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 08/bookinfo-app/database/helmfile.yaml apply

helmfile -f 08/bookinfo-app/details/helmfile.yaml apply

helmfile -f 08/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 08/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f 08/bookinfo-app/reviews/helmfile.yaml apply
```

16. Telemetryリソースをデプロイします。

```bash
kubectl apply --server-side -f 08/shared/telemetry.yaml
```

17. Istiod EgressGatewayをデプロイします。

```bash
helmfile -f 08/istio/istio-egress/helmfile.yaml apply
```

18. Istioコントロールプレーンをデプロイします。

```bash
helmfile -f 08/istio/istio-istiod/helmfile.yaml apply
```
