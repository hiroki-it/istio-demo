# 8章

8章では、テレメトリーを監視します。

## セットアップ

### PrometheusとGrafana

1. Prometheusのカスタムリソース定義をデプロイする。

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

2. PrometheusとGrafanaをデプロイする。

```bash
helmfile -f 08/prometheus/kube-prometheus-stack/helmfile.yaml apply
```

3. Prometheusのダッシュボードに接続します。ブラウザからPodの`9090`番ポートに接続してください。

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus -n istio-system 9090:9090
```

4. Grafanaのダッシュボードに接続します。ブラウザからPodの`8000`番ポートに接続してください。

```bash
kubectl port-forward svc/kube-prometheus-stack-grafana -n istio-system 8000:80
```

### Kiali

5. Kialiをデプロイします。

```bash
helmfile -f 08/kiali/kiali-server/helmfile.yaml apply
```

6. Kialiのダッシュボードに接続します。ブラウザからPodの`20001`番ポートに接続してください。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

### Minio

7. Minioをデプロイします。

```bash
helmfile -f 08/minio/helmfile.yaml apply
```

### Grafana Loki

8. Grafana Lokiをデプロイします。

```bash
helmfile -f 08/grafana/grafana-loki/helmfile.yaml apply
```

### Grafana Promtail

9. Grafana Promtailをデプロイします。

```bash
helmfile -f 08/grafana/grafana-promtail/helmfile.yaml apply
```

### Grafana Tempo

10. Grafana Tempoをデプロイします。

```bash
helmfile -f 08/grafana/grafana-tempo/helmfile.yaml apply
```

### OpenTelemetry Collector

11. OpenTelemetry Collectorをデプロイします。

```bash
helmfile -f 08/opentelemetry/opentelemetry-collector/helmfile.yaml apply
```

### Istio

12. Telemetryリソースをデプロイします。

```bash
kubectl apply --server-side -f 08/shared/telemetry.yaml
```

13. Istiod EgressGatewayをデプロイします。

```bash
helmfile -f 08/istio/istio-egress/helmfile.yaml apply
```

14. Istioコントロールプレーンをデプロイします。

```bash
helmfile -f 08/istio/istio-istiod/helmfile.yaml apply
```
