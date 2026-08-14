# 10章

## セットアップ

### 一括でセットアップ

通常は、リポジトリのルートで次のコマンドを実行してください。

```bash:ターミナル
./chapter-10/setup.sh
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

3. Namespace を作成します。`.metadata` キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash:ターミナル
kubectl apply --server-side -f chapter-10/shared/namespace.yaml
```

4. Bookinfo アプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply --set vSystemFailure.enabled=true

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

5. Istiod コントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-10/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-10/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGateway を作成します。

```bash:ターミナル
helmfile -f chapter-10/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGateway を作成します。

```bash:ターミナル
helmfile -f chapter-10/istio/istio-egress/helmfile.yaml apply
```

8. Istio の L4/L7 トラフィック管理系リソースを作成します。

```bash:ターミナル
helmfile -f chapter-10/bookinfo-app/mysql-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/ratings-istio/helmfile.non-resiliency.yaml apply

helmfile -f chapter-10/bookinfo-app/reviews-istio/helmfile.yaml apply

helmfile -f chapter-10/bookinfo-app/shared-istio/helmfile.yaml apply
```

9. Kubernetes Pod をロールアウトし、Bookinfo アプリケーションの Pod に `istio-proxy` をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

10. Prometheus を作成します。

```bash:ターミナル
helmfile -f chapter-10/prometheus/helmfile.yaml apply
```

11. metrics-server を作成します。

```bash:ターミナル
helmfile -f chapter-10/metrics-server/helmfile.yaml apply
```

12. Grafana を作成します。

```bash:ターミナル
helmfile -f chapter-10/grafana/grafana/helmfile.yaml apply
```

13. Kiali を作成します。

```bash:ターミナル
helmfile -f chapter-10/kiali/helmfile.yaml apply
```

14. Prometheus、Grafana、Kiali のダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続します。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 3000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

15. `http://localhost:9080/productpage?u=normal` から、Bookinfo アプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 8080:8080 9080:9080
```

## 実践する

書籍の 10 章を参照してください。

## 掃除

1. Minikube を削除します。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. `kubectl port-forward` コマンドのプロセスを明示的に終了します。

```bash:ターミナル
pkill kubectl -9
```

3. docker コンテナを削除します。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml down --volumes --remove-orphans
```

4. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) をあらためて実施します。
