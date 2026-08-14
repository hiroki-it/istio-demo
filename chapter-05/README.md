# 5章

## セットアップ

### 一括でセットアップ

通常は、リポジトリのルートで次のコマンドを実行してください。

```bash:ターミナル
./chapter-05/setup.sh
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

2. Namespace を作成します。`.metadata` キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash:ターミナル
kubectl apply --server-side -f chapter-05/shared/namespace.yaml
```

3. Bookinfo アプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details-app/helmfile.yaml apply --set trafficManagement.enabled=true

helmfile -f bookinfo-app/productpage-app/helmfile.yaml apply --set env.loggedIn=true

helmfile -f bookinfo-app/ratings-app/helmfile.yaml apply

helmfile -f bookinfo-app/reviews-app/helmfile.yaml apply --set trafficManagement.enabled=true
```

4. Istiod コントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-05/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-05/istio/istio-istiod/helmfile.yaml apply
```

5. Istio IngressGateway を作成します。

```bash:ターミナル
helmfile -f chapter-05/istio/istio-ingress/helmfile.yaml apply
```

6. Istio EgressGateway を作成します。

```bash:ターミナル
helmfile -f chapter-05/istio/istio-egress/helmfile.yaml apply
```

7. Istio の L4/L7 トラフィック管理系リソースを作成します。

```bash:ターミナル
helmfile -f chapter-05/bookinfo-app/mysql-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/details-istio/helmfile.only-v3.yaml apply

helmfile -f chapter-05/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/productpage-istio/helmfile.only-v2.yaml apply

helmfile -f chapter-05/bookinfo-app/ratings-istio/helmfile.only-v3.yaml apply

helmfile -f chapter-05/bookinfo-app/reviews-istio/helmfile.only-v4.yaml apply
```

8. Kubernetes Pod をロールアウトし、Bookinfo アプリケーションの Pod に `istio-proxy` をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

9. Prometheus を作成します。

```bash:ターミナル
helmfile -f chapter-05/prometheus/helmfile.yaml apply
```

10. metrics-server を作成します。

```bash:ターミナル
helmfile -f chapter-05/metrics-server/helmfile.yaml apply
```

11. Grafana を作成します。

```bash:ターミナル
helmfile -f chapter-05/grafana/grafana/helmfile.yaml apply
```

12. Kiali を作成します。

```bash:ターミナル
helmfile -f chapter-05/kiali/helmfile.yaml apply
```

13. Prometheus、Grafana、Kiali のダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続します。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 3000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

14. `http://localhost:9080/productpage?u=normal` から、Bookinfo アプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

## 実践する

書籍の５章を参照してください。

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
