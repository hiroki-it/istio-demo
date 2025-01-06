# 8章

8章では、テレメトリーを監視します。

1. カスタムリソース定義をデプロイする。

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

3. Prometheusのダッシュボードに接続します。ブラウザから`9090`番ポートに接続してください。

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus -n istio-system 9090:9090
```

3. Grafanaのダッシュボードに接続します。ブラウザから`8000`番ポートに接続してください。

```bash
# ユーザ名: admin
# パスワード: prom-operator
kubectl port-forward svc/kube-prometheus-stack-grafana -n istio-system 8000:80
```

4. Kialiをデプロイします。

```bash
helmfile -f 08/kiali/kiali-server/helmfile.yaml apply
```

5. Kialiのダッシュボードに接続します。ブラウザから`20001`番ポートに接続してください。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

6. Grafana Lokiをデプロイします。

```bash
helmfile -f 08/grafana/grafana-loki/helmfile.yaml apply
```

7. Grafana Tempoをデプロイします。

```bash
helmfile -f 08/grafana/grafana-tempo/helmfile.yaml apply
```
