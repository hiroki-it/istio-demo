# 5章

5章では、Istioのトラフィック管理を学びます。

## 各マイクロサービスをサービスメッシュの管理下にする

1. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 05/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 05/bookinfo-app/reviews/helmfile.yaml apply

helmfile -f 05/bookinfo-app/details/helmfile.yaml apply

helmfile -f 05/bookinfo-app/ratings/helmfile.yaml apply
```

## サービスメッシュ外からの通信を管理する

2. Istio IngressGatewayをデプロイします。

```bash
helmfile -f 05/istio/istio-ingress/helmfile.yaml apply
```

## マイクロサービス間の通信を管理する

## サービスメッシュ外への通信を管理する

3. 外部のサービスとして、MySQLコンテナを作成します。

```bash
docker compose -f 05/mysql/docker-compose.yaml up -d
```

4. Istio EgressGatewayをデプロイします。

```bash
helmfile -f 05/istio/istio-egress/helmfile.yaml apply
```

5. ratingサービスを`v2`にアップグレードします。`v2`は、MySQLに接続処理をもちます。

```bash
kubectl -f https://raw.githubusercontent.com/istio/istio/refs/heads/master/samples/bookinfo/platform/kube/bookinfo-ratings-v2-mysql.yaml apply
```
