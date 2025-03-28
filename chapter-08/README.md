# 8章

以下を実践し、Istioサイドカーモードによるテレメトリー (ログ、メトリクス、分散トレース) 作成を学びます。

- Istioコントロールプレーン、Istio IngressGateway、およびIstio Egress Gatewayを導入する
- Istioのテレメトリー作成系リソース (Telemetry) を作成する

そして、テレメトリー間をトレースIDで紐付け、マイクロサービスアプリケーションのオブザーバビリティーを向上させます

## セットアップ

1. サービスメッシュ外に、MySQLコンテナを作成します。

```bash
docker compose -f databases/docker-compose.yaml up -d
```

2. `keycloak`と`test`というデータベースがあることを確認します。

```bash
docker exec -it istio-demo-mysql /bin/sh

sh-4.4# mysql -h dev.istio-demo-mysql -u root -proot

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| keycloak           |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
```

3. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply --server-side -f chapter-08/shared/namespace.yaml
```

4. Bookinfoアプリケーションを作成します。

```bash
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

5. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-08/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-08/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-08/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成します。

```bash
helmfile -f chapter-08/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-08/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/reviews-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/share-istio/helmfile.yaml apply
```

9. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n bookinfo
```

10. Prometheusを作成します。

```bash
helmfile -f chapter-08/prometheus/helmfile.yaml apply
```

11. metrics-serverを作成します。

```bash
helmfile -f chapter-08/metrics-server/helmfile.yaml apply
```

12. Grafanaを作成します。

```bash
helmfile -f chapter-08/grafana/grafana/helmfile.yaml apply
```

13. Kialiを作成します。

```bash
helmfile -f chapter-08/kiali/helmfile.yaml apply
```

14. Minioを作成します。

```bash
helmfile -f chapter-08/minio/helmfile.yaml apply
```

15. Grafana Lokiを作成します。

```bash
helmfile -f chapter-08/grafana/grafana-loki/helmfile.yaml apply
```

16. Grafana Promtailを作成します。

```bash
helmfile -f chapter-08/grafana/grafana-promtail/helmfile.yaml apply
```

17. Grafana Tempoを作成します。

```bash
helmfile -f chapter-08/grafana/grafana-tempo/helmfile.yaml apply
```

18. OpenTelemetry Collectorを作成します。

```bash
helmfile -f chapter-08/opentelemetry-collector/helmfile.yaml apply
```

19. OpenTelemetry CollectorのPodのログから、istio-proxyの送信したスパンを確認します。

```bash
kubectl logs <OpenTelemetry CollectorのPod> -n opentelemetry-collector -f

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

21. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

22. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

![bookinfo_productpage](../images/bookinfo_productpage.png)

23. `http://localhost:8000`から、Grafanaのダッシュボードに接続します。

```bash
kubectl port-forward svc/grafana -n grafana 8000:80
```

24. 以下のようにGrafana Lokiでログをクエリすると、検索結果のトレースIDの横にView Grafana Tempoボタンが表示されます。これをクリックすると、トレースIDを介して、ログにひもづいたレースを確認できます。

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

```bash
minikube delete --profile istio-demo
```
