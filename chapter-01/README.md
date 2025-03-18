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
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

3. Ingressを作成します。

```bash
helmfile -f chapter-01/ingress/productpage/helmfile.yaml apply
```

4. Nginx Ingress Controllerを作成します。

```bash
helmfile -f chapter-01/nginx/helmfile.yaml apply
```

5. Prometheusを作成します。

```bash
helmfile -f chapter-01/prometheus/helmfile.yaml apply
```

6. Kialiを作成します。

```bash
helmfile -f chapter-10/grafana/kiali/helmfile.yaml apply
```

7. Prometheus、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

8. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 9080:9080
```

![bookinfo_productpage](../images/bookinfo_productpage.png)

9. Bookinfoアプリケーションに定期的にリクエストを送信します。

```bash
$ watch -n 3 curl http://localhost:9080/productpage > /dev/null
```

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

1. Minikubeを削除します。

```bash
minikube delete --profile istio-demo
```

2. `kubectl port-forward`コマンドのプロセスを明示的に終了します。

```
pkill kubectl -9
```
