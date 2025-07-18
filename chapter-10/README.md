# 10章

10章では、Istioによる信頼性管理を学びます。

信頼性管理は、すでに登場したトラフィック管理系リソースのDestinationRuleで設定します。

## セットアップ

1. サービスメッシュ外に、MySQLコンテナを作成します。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml up -d
```

2. `keycloak`と`test`というデータベースがあることを確認します。

```bash:ターミナル
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

```bash:ターミナル
kubectl apply --server-side -f chapter-10/shared/namespace.yaml
```

4. Bookinfoアプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply --set vSystemFailure.enabled=true

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

5. Istiodコントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-10/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-10/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-10/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-10/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash:ターミナル
helmfile -f chapter-10/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/ratings-istio/helmfile.non-resiliency.yaml apply

helmfile -f chapter-10/bookinfo-app/reviews-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/share-istio/helmfile.yaml apply
```

9. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

10. Prometheusを作成します。

```bash:ターミナル
helmfile -f chapter-10/prometheus/helmfile.yaml apply
```

11. metrics-serverを作成します。

```bash:ターミナル
helmfile -f chapter-10/metrics-server/helmfile.yaml apply
```

12. Grafanaを作成します。

```bash:ターミナル
helmfile -f chapter-10/grafana/grafana/helmfile.yaml apply
```

13. Kialiを作成します。

```bash:ターミナル
helmfile -f chapter-10/kiali/helmfile.yaml apply
```

14. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

15. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 8080:8080 9080:9080
```

## 実践する（詳しくは本書を参照）

### リトライ

503ステータスを起因としたリトライを実践します。

```bash:ターミナル
helmfile -f chapter-10/bookinfo-app/ratings-istio/helmfile.retry.yaml apply --set retry.by5xxStatusCode.enabled=true
```

### タイムアウト

タイムアウトを実践します。

```bash:ターミナル
helmfile -f chapter-10/bookinfo-app/ratings-istio/helmfile.timeout.yaml apply
```

### サーキットブレイカー

接続プールに基づくサーキットブレイカーを実践します。

```bash:ターミナル
helmfile -f chapter-10/bookinfo-app/ratings-istio/helmfile.circuit-breaker.yaml apply --set circuitBreaker.byConnectionPool.enabled=true
```

外れ値検出に基づくサーキットブレイカーを実践します。

```bash:ターミナル
helmfile -f chapter-10/bookinfo-app/ratings-istio/helmfile.circuit-breaker.yaml apply --set circuitBreaker.byOutlierDetection.enabled=true
```

接続プールと外れ値検出に基づくサーキットブレイカーを実践します。

```bash:ターミナル
helmfile -f chapter-10/bookinfo-app/ratings-istio/helmfile.circuit-breaker.yaml apply --set circuitBreaker.byConnectionPool.enabled=true --set circuitBreaker.byOutlierDetection.enabled=true
```

## 掃除

1. Minikubeを削除します。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. `kubectl port-forward`コマンドのプロセスを明示的に終了します。

```bash:ターミナル
pkill kubectl -9
```

3. dockerコンテナを削除します。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml down --volumes --remove-orphans
```

4. 他の章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。
