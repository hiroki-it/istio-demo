# 5章

5章では、Istioのトラフィック管理を学びます。

## セットアップ

1. サービスメッシュ外のサービスとして、MySQLコンテナを作成します。

```bash
docker compose -f 05/bookinfo-app/database/docker-compose.yaml up -d
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

3. Istio IngressGatewayをデプロイします。

```bash
helmfile -f 05/istio/istio-ingress/helmfile.yaml apply
```

4. Istio EgressGatewayをデプロイします。

```bash
helmfile -f 05/istio/istio-egress/helmfile.yaml apply
```

5. 各マイクロサービスにIstioカスタムリソースをデプロイします。合わせて、ratingサービスを`v2`にアップグレードします。`v2`は、MySQLに接続処理をもちます。

```bash
helmfile -f 05/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 05/bookinfo-app/reviews/helmfile.yaml apply

helmfile -f 05/bookinfo-app/details/helmfile.yaml apply

helmfile -f 05/bookinfo-app/ratings/helmfile.yaml apply
```

## 機能を実践する

## 掃除する
