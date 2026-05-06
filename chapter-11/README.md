# 11章

## セットアップ

1. サービスメッシュ外に、MySQLコンテナを作成する。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml up -d
```

2. `keycloak` と `test` というデータベースがあることを確認する。

```bash:ターミナル
docker exec -it istio-demo-mysql /bin/sh

sh-4.4# mysql -h dev.istio-demo.mysql.internal -u root -proot

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

3. Namespaceを作成する。`.metadata` キーにアンビエントメッシュの管理下であるラベルを設定している。

```bash:ターミナル
kubectl apply -f chapter-11/shared/namespace.yaml
```

4. Bookinfoアプリケーションを作成する。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply --set trafficManagement.enabled=true

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply --set trafficManagement.enabled=true
```

5. Istiodコントロールプレーンを作成する。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-11/istio/istio-istiod/helmfile.yaml apply
```

6. Istio CNIを作成する。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-cni/helmfile.yaml apply
```

7. Istio Ztunnelを作成する。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-ztunnel/helmfile.yaml apply
```

8. Gateway APIのカスタムリソース定義とIstio Waypointを作成する。

```bash:ターミナル
CRD_VERSION=1.3.0

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml

helmfile -f chapter-11/istio/istio-waypoint-proxy/helmfile.yaml apply
```

9. Istio IngressGatewayを作成する。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-ingress/helmfile.yaml apply
```

9. Istio EgressGatewayを作成する。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-egress/helmfile.yaml apply
```

10. Istioのトラフィック管理系リソースを作成する。

```bash:ターミナル
helmfile -f chapter-11/bookinfo-app/mysql-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/reviews-istio/helmfile.yaml apply
```

11. Kubernetes Podをロールアウトする。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

12. Prometheusを作成する。

```bash:ターミナル
helmfile -f chapter-11/prometheus/helmfile.yaml apply
```

13. metrics-serverを作成する。

```bash:ターミナル
helmfile -f chapter-11/metrics-server/helmfile.yaml apply
```

14. Grafanaを作成する。

```bash:ターミナル
helmfile -f chapter-11/grafana/grafana/helmfile.yaml apply
```

15. Kialiを作成する。

```bash:ターミナル
helmfile -f chapter-11/kiali/helmfile.yaml apply
```

16. Prometheus、Grafana、Kialiのダッシュボードに接続する。ブラウザから、Prometheus (`http://localhost:9090`) 、Grafana (`http://localhost:3000`) 、Kiali (`http://localhost:20001`) に接続する。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 3000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

17. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続する。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

## 実践する

書籍の11章を参照してください。

## 掃除

1. Minikubeを削除する。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) をあらためて実施する。
