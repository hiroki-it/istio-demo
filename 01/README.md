# 1章

1章では、マイクロサービスアーキテクチャーで設計されたBookinfoアプリケーションを構築します。

サービスメッシュツールのIstioを使用せずに、アプリケーションを動かします。

1. Bookinfoアプリケーションをデプロイします。

```bash
ISTIO_VERSION=1.24.1

kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/${ISTIO_VERSION}/samples/bookinfo/platform/kube/bookinfo.yaml
```

2. アプリケーションが正常に稼働していることを確認します。

```bash
kubectl get pod

NAME                             READY   STATUS    RESTARTS   AGE
details-v1-54ffdd5947-cfxwj      1/1     Running   0          8m21s
productpage-v1-d49bb79b4-rt2jh   1/1     Running   0          8m21s
ratings-v1-856f65bcff-jtkkf      1/1     Running   0          8m21s
reviews-v1-848b8749df-7svtl      1/1     Running   0          8m21s
reviews-v2-5fdf9886c7-k9cks      1/1     Running   0          8m21s
reviews-v3-bb6b8ddc7-7jzc8       1/1     Running   0          8m21s
```

3. Nginx Ingress Controllerをデプロイします。

```bash
helmfile -f 01/nginx/ingress-nginx/helmfile.yaml apply     
```
