# 1章

Bookinfoというマイクロサービスアプリケーションを導入します。

BookinfoはIstioのリポジトリで提供されているサンプルであり、これを使用するとIstioの役割を効率的に学べます。

まずは、サービスメッシュのない状況を学ぶために、Nginxを使用してBookinfoアプリケーションに接続します。

## セットアップ

1. MySQLコンテナを作成します。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml up -d
```

2. Namespaceを作成します。

```bash:ターミナル
kubectl apply --server-side -f chapter-00/shared/namespace.yaml
```

3. Bookinfoアプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply loggedIn.enabled=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

4. Ingressを作成します。

```bash:ターミナル
helmfile -f chapter-00/ingress/productpage/helmfile.yaml apply
```

5. Nginx Ingress Controllerを作成します。

```bash:ターミナル
helmfile -f chapter-00/nginx/helmfile.yaml apply
```

6. Prometheusを作成します。

```bash:ターミナル
helmfile -f chapter-00/prometheus/helmfile.yaml apply
```

7. Prometheusのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) に接続してください。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090
```

8. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 9080:9080
```

## 掃除

1. Minikubeを削除します。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. `kubectl port-forward`コマンドのプロセスを明示的に終了します。

```bash:ターミナル
pkill kubectl -9
```

3. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。
