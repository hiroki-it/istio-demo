# 1章

Bookinfoというマイクロサービスアプリケーションを導入します。

BookinfoはIstioのリポジトリで提供されているサンプルであり、これを使用するとIstioの役割を効率的に学べます。

まずは、サービスメッシュのない状況を学ぶために、Nginxを使用してBookinfoアプリケーションに接続します。

## セットアップ

1. Namespaceを作成します。

```bash
kubectl apply --server-side -f chapter-01/shared/namespace.yaml
```

2. Bookinfoアプリケーションを作成します。

```bash
helmfile -f bookinfo-app-istio/details/helmfile.yaml apply

helmfile -f bookinfo-app-istio/productpage/helmfile.yaml apply

helmfile -f bookinfo-app-istio/ratings/helmfile.yaml apply

helmfile -f bookinfo-app-istio/reviews/helmfile.yaml apply
```

3. アプリケーションが正常に稼働していることを確認します。

```bash
kubectl get pod -n app

NAME                             READY   STATUS    RESTARTS   AGE
details-v1-54ffdd5947-cfxwj      1/1     Running   0          8m21s
productpage-v1-d49bb79b4-rt2jh   1/1     Running   0          8m21s
ratings-v1-856f65bcff-jtkkf      1/1     Running   0          8m21s
reviews-v1-848b8749df-7svtl      1/1     Running   0          8m21s
reviews-v2-5fdf9886c7-k9cks      1/1     Running   0          8m21s
reviews-v3-bb6b8ddc7-7jzc8       1/1     Running   0          8m21s
```

3. Ingressを作成します。

```bash
helmfile -f chapter-01/ingress/productpage/helmfile.yaml apply
```

4. Nginx Ingress Controllerを作成します。

```bash
helmfile -f chapter-01/nginx/helmfile.yaml apply
```

5. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 9080:9080
```

![bookinfo_productpage](../images/bookinfo_productpage.png)

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

```bash
minikube delete --profile istio-demo
```
