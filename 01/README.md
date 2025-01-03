# 1章

1章では、マイクロサービスアーキテクチャーで設計されたBookinfoアプリケーションに接続します。

まずは、サービスメッシュツールのIstioを使用せずに、接続してみます。

## セットアップ

1. Bookinfoアプリケーションをデプロイします。

```bash
ISTIO_VERSION=1.24.2

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

3. Bookinfoアプリケーション用のIngressを事前に作成します。

```bash
kubectl -f 01/k8s-manifests/ingress.yaml apply
```

4. Namespaceを事前に作成します。

```bash
kubectl -f 01/k8s-manifests/namespace.yaml apply
```

5. Nginx Ingress Controllerをデプロイします。

```bash
helmfile -f 01/nginx/ingress-nginx/helmfile.yaml apply
```

6. Nginx Ingress ControllerのNodePort Serviceを介して、Bookinfoアプリケーションに接続します。ローカルホストでポート番号が発行されるため、ブラウザから接続してください。

```bash
minikube service ingress-nginx-controller --url -n ingress-nginx

http://127.0.0.1:<発行されたポート番号>
```

## 機能を実践する

7. [Normal user](http://127.0.0.1:59594/productpage?u=normal) をクリックし、The Comedy of Errorsページを閲覧できることを確認する。

## 掃除する

8. 接続を確認できたら、以降の章で不要なリソースを削除します。

```bash
$ kubectl -f 01/k8s-manifests/ingress.yaml delete

$ kubectl -f 01/k8s-manifests/namespace.yaml delete

$ helmfile -f 01/nginx/ingress-nginx/helmfile.yaml destroy
```
