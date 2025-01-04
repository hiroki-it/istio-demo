# 5章

5章では、Istioのトラフィック管理を学びます。

## セットアップ

1. サービスメッシュ外にMySQLコンテナを作成します。

```bash
docker compose -f 05/bookinfo-app/ratings/docker-compose.yaml up -d
```

2. 次のようなテーブルを持つMySQLコンテナです。

```bash
docker exec -it mysql /bin/sh
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

5. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 05/bookinfo-app/details/helmfile.yaml apply

helmfile -f 05/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 05/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f 05/bookinfo-app/reviews/helmfile.yaml apply
```

## 機能を実践する

## 掃除する
