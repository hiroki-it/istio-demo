# 8章

8章では、テレメトリーを監視します。

## メトリクスを監視する

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

3. メトリクスの監視ダッシュボードに接続します。

```bash
kubectl port-forward svc/kube-prometheus-stack-prometheus -n prometheus 9090:9090

kubectl port-forward svc/kube-prometheus-stack-alertmanager -n prometheus 9093:9093

# ユーザ名: admin
# パスワード: prom-operator
kubectl port-forward svc/kube-prometheus-stack-grafana -n prometheus 8000:80
```

## メッシュトポロジーを監視する

4. Kialiをデプロイします。

```bash
helmfile -f 08/kiali/helmfile.yaml apply
```

5. メッシュトポロジーの監視ダッシュボードに接続します。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```
