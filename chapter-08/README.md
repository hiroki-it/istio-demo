# 8章

8章では、Istioによるテレメトリー (ログ、メトリクス、分散トレース) 作成を学びます。

テレメトリー作成系リソース (Telemetry) を使用して、Istioがテレメトリーを作成する様子を確認します。

また、テレメトリー間をトレースIDで紐付け、マイクロサービスアプリケーションのオブザーバビリティーを向上させます。

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

3. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply --server-side -f chapter-08/shared/namespace.yaml
```

4. Prometheusを作成します。

```bash
helmfile -f chapter-08/prometheus/helmfile.yaml apply
```

5. Grafanaを作成します。

```bash
helmfile -f chapter-08/grafana/grafana/helmfile.yaml apply
```

6. Kialiを作成します。

```bash
helmfile -f chapter-08/kiali/helmfile.yaml apply
```

7. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n istio-system 9090:9090 & \
  kubectl port-forward svc/grafana -n istio-system 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

10. Minioを作成します。

```bash
helmfile -f chapter-08/minio/helmfile.yaml apply
```

11. Grafana Lokiを作成します。

```bash
helmfile -f chapter-08/grafana/grafana-loki/helmfile.yaml apply
```

12. Grafana Promtailを作成します。

```bash
helmfile -f chapter-08/grafana/grafana-promtail/helmfile.yaml apply
```

13. Grafana Tempoを作成します。

```bash
helmfile -f chapter-08/grafana/grafana-tempo/helmfile.yaml apply
```

14. OpenTelemetry Collectorを作成します。

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

16. Istioコントロールプレーンを作成します。

```bash
helmfile -f chapter-08/istio/istio-istiod/helmfile.yaml apply
```

17. Telemetryを作成します。

```bash
helmfile -f chapter-07/istio/istio-telemetry/helmfile.yaml apply
```

18. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-07/istio/istio-ingress/helmfile.yaml apply
```

19. Istiod EgressGatewayを作成します。

```bash
helmfile -f chapter-08/istio/istio-egress/helmfile.yaml apply
```

20. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-08/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/reviews/helmfile.yaml apply
```

21. `http://localhost:8000`から、Grafanaのダッシュボードに接続します。

```bash
kubectl port-forward svc/grafana -n istio-system 8000:80
```

22. 以下のようにGrafana Lokiでログをクエリすると、検索結果のトレースIDの横にView Grafana Tempoボタンが表示されます。これをクリックすると、トレースIDを介して、ログにひもづいたレースを確認できます。
