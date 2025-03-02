# 8章

以下を実践することにより、Istioサイドカーモードによる証明書管理を学びます。

- Istioコントロールプレーン、Istio IngressGateway、およびIstio Egress Gatewayを導入する
- 証明書管理系リソース (PeerAuthentication) を作成します

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply --server-side -f chapter-08/shared/namespace.yaml
```

2. Bookinfoアプリケーションを作成します。

```bash
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

3. サービスメッシュ外に、Ratingサービス用のMySQLコンテナを作成します。

```bash
docker compose -f chapter-08/bookinfo-app/ratings-istio/docker-compose.yaml up -d
```

4. `test`データベースは`rating`テーブルを持つことを確認します。

```bash
docker exec -it ratings-mysql /bin/sh

sh-4.4# mysql -h ratings.mysql.dev -u root -proot

mysql> SHOW TABLES FROM test;
+----------------+
| Tables_in_test |
+----------------+
| ratings        |
+----------------+

mysql> USE test;

mysql> SELECT * from ratings;
+----------+--------+
| ReviewID | Rating |
+----------+--------+
|        1 |      5 |
|        2 |      4 |
+----------+--------+
```

5. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-08/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-08/istio/istio-istiod/helmfile.yaml apply
```

9. PeerAuthenticationを作成します。

```bash
helmfile -f chapter-08/istio/istio-peer-authentication/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-08/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成します。

```bash
helmfile -f chapter-08/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-08/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-08/bookinfo-app/reviews-istio/helmfile.yaml apply
```

9. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n bookinfo
```

10. Prometheusを作成します。

```bash
helmfile -f chapter-08/prometheus/helmfile.yaml apply
```

11. metrics-serverを作成します。

```bash
helmfile -f chapter-08/metrics-server/helmfile.yaml apply
```

12. Grafanaを作成します。

```bash
helmfile -f chapter-08/grafana/grafana/helmfile.yaml apply
```

13. Kialiを作成します。

```bash
helmfile -f chapter-05/kiali/helmfile.yaml apply
```

14. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

15. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 8080:8080 9080:9080
```

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

```bash
minikube delete --profile istio-demo
```
