# 6章

6章では、Istioによる回復性管理を学びます。

回復性管理は、すでに登場したトラフィック管理系リソースのDestinationRuleで設定します。

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply --server-side -f chapter-06/shared/namespace.yaml
```

2. Bookinfoアプリケーションを作成します。

```bash
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

3. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-06/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/reviews-istio/helmfile.yaml apply
```

4. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n bookinfo
```

## 機能を実践する

## 掃除

1. Minikubeを削除します。

```bash
minikube delete --profile istio-demo
```

2. dockerコンテナを削除します。

```bash
docker compose -f chapter-06/bookinfo-app/ratings-istio/docker-compose.yaml down --rmi all --volumes --remove-orphans
```

3. 他の章を実践するときは、事前に [Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。
