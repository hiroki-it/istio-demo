# 11章

## セットアップ

### 一括でセットアップ

通常は、リポジトリのルートで次のコマンドを実行してください。

```bash:ターミナル
./chapter-11/setup.sh
```

### 個別にセットアップ

1. サービスメッシュ外に、MySQL コンテナを作成します。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml up -d
```

2. `keycloak` と `test` というデータベースがあることを確認します。

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

3. Namespace を作成します。`.metadata` キーにアンビエントメッシュの管理下であるラベルを設定しています。

```bash:ターミナル
kubectl apply -f chapter-11/shared/namespace.yaml
```

4. Bookinfo アプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details-app/helmfile.yaml apply --set trafficManagement.enabled=true

helmfile -f bookinfo-app/productpage-app/helmfile.yaml apply --set env.loggedIn=true

helmfile -f bookinfo-app/ratings-app/helmfile.yaml apply

helmfile -f bookinfo-app/reviews-app/helmfile.yaml apply --set trafficManagement.enabled=true
```

5. Istiod コントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-11/istio/istio-istiod/helmfile.yaml apply
```

6. Istio CNI を作成します。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-cni/helmfile.yaml apply
```

7. Istio Ztunnel を作成します。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-ztunnel/helmfile.yaml apply
```

8. Gateway API のカスタムリソース定義と Istio Waypoint を作成します。

```bash:ターミナル
CRD_VERSION=1.5.1

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml

helmfile -f chapter-11/istio/istio-waypoint-proxy/helmfile.yaml apply
```

9. Istio IngressGateway を作成します。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-ingress/helmfile.yaml apply
```

9. Istio EgressGateway を作成します。

```bash:ターミナル
helmfile -f chapter-11/istio/istio-egress/helmfile.yaml apply
```

10. Istio の L4/L7 トラフィック管理系リソースを作成します。

```bash:ターミナル
helmfile -f chapter-11/bookinfo-app/mysql-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/reviews-istio/helmfile.yaml apply
```

11. Kubernetes Pod をロールアウトします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

12. Prometheus を作成します。

```bash:ターミナル
helmfile -f chapter-11/prometheus/helmfile.yaml apply
```

13. Kubernetes Metrics Server を作成します。

```bash:ターミナル
helmfile -f chapter-11/metrics-server/helmfile.yaml apply
```

14. Grafana を作成します。

```bash:ターミナル
helmfile -f chapter-11/grafana/grafana/helmfile.yaml apply
```

15. Kiali を作成します。

```bash:ターミナル
helmfile -f chapter-11/kiali/helmfile.yaml apply
```

16. Prometheus、Grafana、Kiali のダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:9090`) 、Grafana (`http://localhost:3000`) 、Kiali (`http://localhost:20001`) に接続します。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 3000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

17. `http://localhost:9080/productpage?u=normal` から、Bookinfo アプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

## 実践する

書籍の 11 章を参照してください。

## 掃除

1. Minikube を削除します。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) をあらためて実施します。
