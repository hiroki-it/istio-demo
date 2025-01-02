# 5章

5章では、Istioのトラフィック管理を学びます。

## サービスメッシュ外にDBを作成する

1. サービスメッシュ外のサービスとして、MySQLコンテナを作成します。

```bash
docker compose -f 05/mysql/docker-compose.yaml up -d
```

2. 次のようなテーブルを持つMySQLコンテナです。

```bash
docker exec -it mysqldb /bin/sh
                                                                                                                                                                              (minikube/default)
sh-4.4# mysql -h localhost -u root -ppassword

mysql> USE test
mysql> SELECT * from ratings;
+----------+--------+
| ReviewID | Rating |
+----------+--------+
|        1 |      5 |
|        2 |      4 |
+----------+--------+
```

## サービスメッシュ外からの通信を管理する

3. Istio IngressGatewayをデプロイします。

```bash
helmfile -f 05/istio/istio-ingress/helmfile.yaml apply
```

4. Istio EgressGatewayをデプロイします。

```bash
helmfile -f 05/istio/istio-egress/helmfile.yaml apply
```

## 各マイクロサービスをサービスメッシュの管理下にする

5. ratingサービスを`v2`にアップグレードします。`v2`は、MySQLに接続処理をもちます。

```bash
ISTIO_VERSION=1.24.2

kubectl -f https://raw.githubusercontent.com/istio/istio/refs/tags/${ISTIO_VERSION}/samples/bookinfo/platform/kube/bookinfo-ratings-v2-mysql.yaml apply
```

6. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 05/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 05/bookinfo-app/reviews/helmfile.yaml apply

helmfile -f 05/bookinfo-app/details/helmfile.yaml apply

helmfile -f 05/bookinfo-app/ratings/helmfile.yaml apply
```
