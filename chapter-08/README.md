# 8章

8章では、テレメトリーを監視します。

## セットアップ

1. サービスメッシュ外に、Ratingサービス用のMySQLコンテナを作成します。

```bash
docker compose -f chapter-05/bookinfo-app/ratings/docker-compose.yaml up -d
```

2. `test`データベースは`rating`テーブルを持つことを確認します。

```bash
docker exec -it ratings-mysql /bin/sh

sh-4.4# mysql -h ratings.mysql.dev -u root -proot

mysql> SHOW TABLES FROM test;
+----------------+
| Tables_in_test |
+----------------+
| ratings        |
+----------------+

mysql> USE test;

mysql> SELECT * from ratings;
+----------+--------+
| ReviewID | Rating |
+----------+--------+
|        1 |      5 |
|        2 |      4 |
+----------+--------+
```

3. Namespaceをデプロイします。

```bash
kubectl apply --server-side -f chapter-08/shared/namespace.yaml
```

### Prometheus

4. Prometheusをデプロイします。

```bash
helmfile -f chapter-08/prometheus/helmfile.yaml apply
```

5. Prometheusのダッシュボードに接続します。ブラウザからPodの`9090`番ポートに接続してください。

```bash
kubectl port-forward svc/prometheus-server -n istio-system 9090:9090
```

6. Grafanaをデプロイします。

```bash
helmfile -f chapter-08/grafana/grafana/helmfile.yaml apply
```

7. Grafanaのダッシュボードに接続します。ブラウザからPodの`8000`番ポートに接続してください。

```bash
kubectl port-forward svc/grafana -n istio-system 8000:80
```

### Kiali

8. Kialiをデプロイします。

```bash
helmfile -f chapter-08/kiali/helmfile.yaml apply
```

9. Kialiのダッシュボードに接続します。ブラウザからPodの`20001`番ポートに接続してください。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

### Minio

10. Minioをデプロイします。

```bash
helmfile -f chapter-08/minio/helmfile.yaml apply
```

### Grafana Loki

11. Grafana Lokiをデプロイします。

```bash
helmfile -f chapter-08/grafana/grafana-loki/helmfile.yaml apply
```

### Grafana Promtail

12. Grafana Promtailをデプロイします。

```bash
helmfile -f chapter-08/grafana/grafana-promtail/helmfile.yaml apply
```

### Grafana Tempo

13. Grafana Tempoをデプロイします。

```bash
helmfile -f chapter-08/grafana/grafana-tempo/helmfile.yaml apply
```

### OpenTelemetry Collector

14. OpenTelemetry Collectorをデプロイします。

```bash
helmfile -f chapter-08/opentelemetry-collector/helmfile.yaml apply
```

15. OpenTelemetry CollectorのPodのログから、istio-proxyの送信したスパンを確認します。

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

16. Istioコントロールプレーンをデプロイします。

```bash
helmfile -f chapter-08/istio/istio-istiod/helmfile.yaml apply
```

17. Telemetryリソースをデプロイします。

```bash
kubectl apply --server-side -f chapter-08/shared/telemetry.yaml
```

18. Istiod EgressGatewayをデプロイします。

```bash
helmfile -f chapter-08/istio/istio-egress/helmfile.yaml apply
```

19. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f chapter-08/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/reviews/helmfile.yaml apply
```
