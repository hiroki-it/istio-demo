# 付録

付録では、Istio サイドカーモードと Gateway API の統合を学びます。

Istio の L4/L7 トラフィック管理系リソースの一部は、Gateway API リソースに置き換えられます。

ただし、以下の注意点があります。

- Gateway API を適用したい Namespace をサービスメッシュの管理下にする必要がある
- Gateway API で代替できる Istio の機能は、執筆時点でトラフィック管理の一部のみである
- Kiali は Istio のトラフィック系リソースのメトリクスに基づいてメッシュトポロジーを作成しているため、Kiali のダッシュボード上でメッシュトポロジーを確認できなくなる

## セットアップ

### 一括でセットアップ

通常は、リポジトリのルートで次のコマンドを実行してください。

```bash:ターミナル
./chapter-extra/setup.sh
```

### 個別にセットアップ

1. サービスメッシュ外に、MySQL コンテナを作成します。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml up -d
```

2. Namespace を作成します。`.metadata` キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash:ターミナル
kubectl apply --server-side -f chapter-extra/shared/namespace.yaml
```

3. Bookinfo アプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

4. Istiod コントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-extra/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-extra/istio/istio-istiod/helmfile.yaml apply
```

5. Gateway API のカスタムリソース定義を作成します。

```bash:ターミナル
CRD_VERSION=1.5.1

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml
```

6. Istio IngressGateway を作成します。

```bash:ターミナル
helmfile -f chapter-extra/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGateway を作成します。

```bash:ターミナル
helmfile -f chapter-extra/istio/istio-egress/helmfile.yaml apply
```

8. Istio の L4/L7 トラフィック管理系リソースを Gateway API リソースに置き換えます。

```bash:ターミナル
helmfile -f chapter-extra/bookinfo-app/mysql-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/reviews-istio/helmfile.yaml apply
```

9. Kubernetes Pod をロールアウトし、Bookinfo アプリケーションの Pod に `istio-proxy` をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

10. Prometheus を作成します。

```bash:ターミナル
helmfile -f chapter-extra/prometheus/helmfile.yaml apply
```

11. Grafana を作成します。

```bash:ターミナル
helmfile -f chapter-extra/grafana/grafana/helmfile.yaml apply
```

12. Kiali を作成します。

```bash:ターミナル
helmfile -f chapter-extra/kiali/helmfile.yaml apply
```

13. Prometheus、Grafana、Kiali のダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続します。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 3000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

14. `http://localhost:9080/productpage?u=normal` から、Bookinfo アプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingress-istio -n istio-ingress 9080:9080
```

## 掃除

1. Minikube を削除します。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) をあらためて実施します。
