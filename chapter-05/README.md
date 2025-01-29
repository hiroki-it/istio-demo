# 5章

5章では、Istioによるトラフィック管理を学びます。

Istioカスタムリソース (DestinationRule、Gateway、ServiceEntry、VirtualService) を使用して、IstioがL4やL7のトラフィックを管理する様子を確認します。

## セットアップ

1. サービスメッシュ外に、Ratingサービス用のMySQLコンテナを作成します。

```bash
docker compose -f chapter-05/bookinfo-app/ratings/docker-compose.yaml up -d
```

2. `test`データベースは`rating`テーブルを持つことを確認します。

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

2. Namespaceをデプロイします。

```bash
kubectl apply --server-side -f chapter-05/shared/namespace.yaml
```

3. Istio IngressGatewayをデプロイします。

```bash
helmfile -f chapter-05/istio/istio-ingress/helmfile.yaml apply
```

4. Istio EgressGatewayをデプロイします。

```bash
helmfile -f chapter-05/istio/istio-egress/helmfile.yaml apply
```

5. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f chapter-05/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-05/bookinfo-app/reviews/helmfile.yaml apply
```

6. Istio IngressGatewayのNodePort Serviceを介して、Bookinfoアプリケーションに接続します。ブラウザから、発行されたURLに接続してください。

```bash
minikube service istio-ingressgateway -n istio-ingress --profile istio-demo --url
```

7. Bookinfoアプリケーションに接続し、**Normal user**をクリックします。

![bookinfo](../images/bookinfo.png)

8. Productpageに接続します。

![bookinfo_productpage](../images/bookinfo_productpage.png)

## 機能を実践する
