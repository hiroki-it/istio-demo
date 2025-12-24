# 9章

9章では、Istioによるブラックボックステストを学びます。

Istioでは、ブラックボックスとしてフォールとインジェクションを使用でき、障害時のマイクロサービスの挙動を事前に確認しておくことができます。

ブラックボックステストは、すでに登場したトラフィック管理系リソースのVirtualServiceで設定します。

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
kubectl apply --server-side -f chapter-09/shared/namespace.yaml
```

4. Bookinfoアプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

5. Istiodコントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-09/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-09/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-09/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-09/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash:ターミナル
helmfile -f chapter-09/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/reviews-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/share-istio/helmfile.yaml apply
```

9. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

10. Prometheusを作成します。

```bash:ターミナル
helmfile -f chapter-09/prometheus/helmfile.yaml apply
```

11. metrics-serverを作成します。

```bash:ターミナル
helmfile -f chapter-09/metrics-server/helmfile.yaml apply
```

12. Grafanaを作成します。

```bash:ターミナル
helmfile -f chapter-09/grafana/grafana/helmfile.yaml apply
```

13. Kialiを作成します。

```bash:ターミナル
helmfile -f chapter-09/kiali/helmfile.yaml apply
```

14. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 3000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

15. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 8080:8080 9080:9080
```

## 実践する

書籍の９章を参照してください。

### 遅延障害の注入

遅延障害を正常なマイクロサービスに注入します。

```bash:ターミナル
helmfile -f chapter-09/bookinfo-app/ratings-istio/helmfile.delayed.yaml apply
```

### 503ステータスの注入

503ステータスレスポンスの障害を正常なマイクロサービスに注入します。

```bash:ターミナル
helmfile -f chapter-09/bookinfo-app/ratings-istio/helmfile.503-status.yaml apply
```

### 500ステータスの注入

500ステータスレスポンスの障害を正常なマイクロサービスに注入します。

```bash:ターミナル
helmfile -f chapter-09/bookinfo-app/ratings-istio/helmfile.500-status.yaml apply
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

4. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。
