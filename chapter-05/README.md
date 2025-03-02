# 5章

以下を実践することにより、Istioサイドカーモードによるトラフィック管理を学びます。

- Istioコントロールプレーン、Istio IngressGateway、およびIstio Egress Gatewayを導入する
- Istioのトラフィック管理系リソース (DestinationRule、Gateway、ServiceEntry、VirtualService) を作成する

これらのリソースはサービスメッシュに必須であり、以降の全ての章で登場します。

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply --server-side -f chapter-05/shared/namespace.yaml
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
docker compose -f chapter-05/bookinfo-app/ratings-istio/docker-compose.yaml up -d
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
helmfile -f chapter-05/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-05/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-05/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成します。

```bash
helmfile -f chapter-05/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-05/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/reviews-istio/helmfile.yaml apply
```

9. Prometheusを作成します。

```bash
helmfile -f chapter-05/prometheus/helmfile.yaml apply
```

10. metrics-serverを作成します。

```bash
helmfile -f chapter-09/metrics-server/helmfile.yaml apply
```

11. Kialiを作成します。

```bash
helmfile -f chapter-05/kiali/helmfile.yaml apply
```

12. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n istio-system 9090:9090 & \
  kubectl port-forward svc/grafana -n istio-system 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

13. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

![bookinfo_productpage](../images/bookinfo_productpage.png)

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

```bash
minikube delete --profile istio-demo
```
