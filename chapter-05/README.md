# 5章

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

2. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash:ターミナル
kubectl apply --server-side -f chapter-05/shared/namespace.yaml
```

3. Bookinfoアプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply --set trafficManagement.enabled=true

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply --set trafficManagement.enabled=true

helmfile -f bookinfo-app/reviews/helmfile.yaml apply --set trafficManagement.enabled=true
```

4. Istiodコントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-05/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-05/istio/istio-istiod/helmfile.yaml apply
```

5. Istio IngressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-05/istio/istio-ingress/helmfile.yaml apply
```

6. Istio EgressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-05/istio/istio-egress/helmfile.yaml apply
```

7. Istioのトラフィック管理系リソースを作成します。

```bash:ターミナル
helmfile -f chapter-05/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/reviews-istio/helmfile.yaml apply
```

8. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

9. Prometheusを作成します。

```bash:ターミナル
helmfile -f chapter-05/prometheus/helmfile.yaml apply
```

10. metrics-serverを作成します。

```bash:ターミナル
helmfile -f chapter-05/metrics-server/helmfile.yaml apply
```

11. Grafanaを作成します。

```bash:ターミナル
helmfile -f chapter-05/grafana/grafana/helmfile.yaml apply
```

12. Kialiを作成します。

```bash:ターミナル
helmfile -f chapter-05/kiali/helmfile.yaml apply
```

13. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

14. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

## 実践する（詳しくは本書を参照）

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
