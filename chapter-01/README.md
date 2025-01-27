# 1章

1章では、マイクロサービスアーキテクチャーで設計されたBookinfoアプリケーションに接続します。

まずは、サービスメッシュツールのIstioを使用せずに、接続してみます。

## セットアップ

1. Namespaceをデプロイします。

```bash
kubectl apply --server-side -f chapter-01/shared/namespace.yaml
```

2. Bookinfoアプリケーションをデプロイします。

```bash
helmfile -f chapter-01/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-01/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-01/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-01/bookinfo-app/reviews/helmfile.yaml apply
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

3. Ingressをデプロイします。

```bash
helmfile -f chapter-01/ingress/productpage/helmfile.yaml apply
```

4. Nginx Ingress Controllerをデプロイします。

```bash
helmfile -f chapter-01/nginx/helmfile.yaml apply
```

6. Nginx Ingress ControllerのNodePort Serviceを介して、Bookinfoアプリケーションに接続します。ブラウザから、発行されたURLに接続してください。

```bash
minikube service ingress-nginx-controller -n ingress-nginx --profile istio-demo --url
```

7. Bookinfoアプリケーションに接続し、**Normal user**をクリックします。

![bookinfo](../images/bookinfo.png)

8. Productpageに接続します。

![bookinfo_productpage](../images/bookinfo_productpage.png)

## 掃除する

1. 以降の章ではIngressとNginx Ingress Controllerは不要であるため、削除します。

```bash
helmfile -f chapter-01/ingress/productpage/helmfile.yaml destroy

helmfile -f chapter-01/nginx/helmfile.yaml destroy
```
