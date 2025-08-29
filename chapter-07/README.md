# 7章

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
kubectl apply --server-side -f chapter-07/shared/namespace.yaml
```

4. Bookinfoアプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

5. Istiodコントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-07/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-07/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-07/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-07/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash:ターミナル
helmfile -f chapter-07/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/reviews-istio/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/share-istio/helmfile.yaml apply
```

9. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

10. Keycloakを作成します。

```bash:ターミナル
helmfile -f chapter-07/keycloak/helmfile.yaml apply
```

11. Prometheusを作成します。

```bash:ターミナル
helmfile -f chapter-07/prometheus/helmfile.yaml apply
```

12. metrics-serverを作成します。

```bash:ターミナル
helmfile -f chapter-07/metrics-server/helmfile.yaml apply
```

13. Grafanaを作成します。

```bash:ターミナル
helmfile -f chapter-07/grafana/grafana/helmfile.yaml apply
```

14. Kialiを作成します。

```bash:ターミナル
helmfile -f chapter-07/kiali/helmfile.yaml apply
```

15. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 3000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

16. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 8080:8080 9080:9080
```

## 実践する

書籍の７章を参照してください。

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
