# 1章

## セットアップ

### 一括でセットアップ

通常は、リポジトリのルートで次のコマンドを実行してください。

```bash:ターミナル
./chapter-00/setup.sh
```

### 個別にセットアップ

1. MySQL コンテナを作成します。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml up -d
```

2. Namespace を作成します。

```bash:ターミナル
kubectl apply --server-side -f chapter-00/shared/namespace.yaml
```

3. Bookinfo アプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

4. Ingress を作成します。

```bash:ターミナル
helmfile -f chapter-00/bookinfo-app/productpage-istio/helmfile.yaml apply
```

5. Nginx Gateway Controller を作成します。

```bash:ターミナル
helmfile -f chapter-00/nginx/helmfile.yaml apply
```

6. Prometheus を作成します。

```bash:ターミナル
helmfile -f chapter-00/prometheus/helmfile.yaml apply
```

7. Prometheus のダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) に接続します。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090
```

8. `http://localhost:9080/productpage?u=normal` から、Bookinfo アプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/ingress-nginx-controller -n ingress-nginx 9080:9080
```

## 掃除

1. Minikube を削除します。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. `kubectl port-forward` コマンドのプロセスを明示的に終了します。

```bash:ターミナル
pkill kubectl -9
```

3. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) をあらためて実施します。
