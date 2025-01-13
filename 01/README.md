# 1章

1章では、マイクロサービスアーキテクチャーで設計されたBookinfoアプリケーションに接続します。

まずは、サービスメッシュツールのIstioを使用せずに、接続してみます。

## セットアップ

1. Namespaceをデプロイします。

```bash
kubectl apply --server-side -f 01/shared/namespace.yaml
```

2. Ingressをデプロイします。

```bash
helmfile -f 01/bookinfo-app/productpage/helmfile.yaml apply
```

3. Nginx Ingress Controllerをデプロイします。

```bash
helmfile -f 01/nginx/ingress-nginx/helmfile.yaml apply
```

4. Nginx Ingress ControllerのNodePort Serviceを介して、Bookinfoアプリケーションに接続します。ブラウザから発行されたURLに接続してください。

```bash
minikube service ingress-nginx-controller -n ingress-nginx --url
```

5. [Normal user](http://127.0.0.1:59594/productpage?u=normal) をクリックし、Bookinfoアプリケーションに接続できることを確認します。

![bookinfo](./images/bookinfo.png)

## 掃除する

1. 接続を確認できたら、以降の章で不要なリソースを削除します。Namespaceの削除に時間がかかるため、待機してください。

```bash
helmfile -f 01/bookinfo-app/productpage/helmfile.yaml destroy

helmfile -f 01/nginx/ingress-nginx/helmfile.yaml destroy

kubectl delete -f 01/shared/namespace.yaml
```
