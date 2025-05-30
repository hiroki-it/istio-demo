# 6章

以下を実践し、Istioサイドカーモードによるパケット暗号化を学びます。

- Istioコントロールプレーン、Istio Ingress Gateway、およびIstio Egress Gatewayを導入する
- パケット暗号化系リソース (PeerAuthentication) を作成します

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
kubectl apply --server-side -f chapter-06/shared/namespace.yaml
```

4. Bookinfoアプリケーションを作成します。

```bash
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

5. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-06/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-06/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-06/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成します。

```bash
helmfile -f chapter-06/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-06/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/reviews-istio/helmfile.yaml apply
```

9. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n bookinfo
```

10. Prometheusを作成します。

```bash
helmfile -f chapter-06/prometheus/helmfile.yaml apply
```

11. metrics-serverを作成します。

```bash
helmfile -f chapter-06/metrics-server/helmfile.yaml apply
```

12. Grafanaを作成します。

```bash
helmfile -f chapter-06/grafana/grafana/helmfile.yaml apply
```

13. Kialiを作成します。

```bash
helmfile -f chapter-06/kiali/helmfile.yaml apply
```

14. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

15. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```


## 機能を実践する

### クライアント証明書の無効化

相互TLS認証を要求されている状態で、ratingsサービスに対するリクエストでクライアント証明書を無効します。

```bash
helmfile -f chapter-06/bookinfo-app/ratings-istio/helmfile.yaml apply --set nonClientCertificate.enabled=true
```

## 掃除

1. Minikubeを削除します。

```bash
minikube delete --profile istio-demo
```

2. `kubectl port-forward`コマンドのプロセスを明示的に終了します。

```bash
pkill kubectl -9
```

3. dockerコンテナを削除します。

```bash
docker compose -f databases/docker-compose.yaml down --volumes --remove-orphans
```

4. 他の章を実践するときは、事前に [Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。
