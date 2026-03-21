# 2章

## セットアップ

1. サービスメッシュ外に、MySQLコンテナを作成する。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml up -d
```

2. `keycloak` と `test` というデータベースがあることを確認する。

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

3. Namespaceを作成する。`.metadata` キーにサービスメッシュの管理下であるリビジョンラベルを設定している。

```bash:ターミナル
kubectl apply --server-side -f chapter-02/shared/namespace.yaml
```

4. Bookinfoアプリケーションを作成する。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

5. Istiodコントロールプレーンを作成する。

```bash:ターミナル
helmfile -f chapter-02/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-02/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGatewayを作成する。

```bash:ターミナル
helmfile -f chapter-02/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成する。

```bash:ターミナル
helmfile -f chapter-02/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成する。

```bash:ターミナル
helmfile -f chapter-02/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-02/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-02/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-02/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-02/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-02/bookinfo-app/reviews-istio/helmfile.yaml apply
```

9. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに `istio-proxy` をインジェクションする。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

10. Prometheusを作成する。

```bash:ターミナル
helmfile -f chapter-02/prometheus/helmfile.yaml apply
```

11. Kialiを作成する。

```bash:ターミナル
helmfile -f chapter-02/kiali/helmfile.yaml apply
```

14. Prometheus、Kialiのダッシュボードに接続する。ブラウザから、Prometheus (`http://localhost:20001`) 、Kiali (`http://localhost:20001`) に接続する。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

12. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続する。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

## 実践する

書籍の２章を参照してください。

## 掃除

1. Minikubeを削除する。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. `kubectl port-forward` コマンドのプロセスを明示的に終了する。

```bash:ターミナル
pkill kubectl -9
```

3. dockerコンテナを削除する。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml down --volumes --remove-orphans
```

4. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) をあらためて実施する。
