# 付録

付録では、IstioサイドカーモードとGateway APIの統合を学びます。

IstioのL4/L7トラフィック管理系リソースの一部は、Gateway APIリソースに置き換えられます。

ただし、以下の注意点があります。

- Gateway APIを適用したい Namespace をサービスメッシュの管理下にする必要がある
- Gateway APIで代替できるIstioの機能は、執筆時点でトラフィック管理の一部のみである
- KialiはIstioのトラフィック系リソースのメトリクスに基づいてメッシュトポロジーを作成しているため、Kialiのダッシュボード上でメッシュトポロジーを確認できなくなる

## セットアップ

1. サービスメッシュ外に、MySQLコンテナを作成する。

```bash:ターミナル
docker compose -f databases/docker-compose.yaml up -d
```

2. Namespaceを作成する。`.metadata` キーにサービスメッシュの管理下であるリビジョンラベルを設定している。

```bash:ターミナル
kubectl apply --server-side -f chapter-extra/shared/namespace.yaml
```

3. Bookinfoアプリケーションを作成する。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

4. Istiodコントロールプレーンを作成する。

```bash:ターミナル
helmfile -f chapter-extra/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-extra/istio/istio-istiod/helmfile.yaml apply
```

5. Gateway APIのカスタムリソース定義を作成する。

```bash:ターミナル
CRD_VERSION=1.5.1

kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml
```

6. Istio IngressGatewayを作成する。

```bash:ターミナル
helmfile -f chapter-extra/istio/istio-ingress/helmfile.yaml apply
```

7. IstioのL4/L7トラフィック管理系リソースをGateway APIリソースに置き換える。

```bash:ターミナル
helmfile -f chapter-extra/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/reviews-istio/helmfile.yaml apply
```

8. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに `istio-proxy` をインジェクションする。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

9. Prometheusを作成する。

```bash:ターミナル
helmfile -f chapter-extra/prometheus/helmfile.yaml apply
```

10. Kialiを作成する。

```bash:ターミナル
helmfile -f chapter-extra/kiali/helmfile.yaml apply
```

11. Prometheus、Kialiのダッシュボードに接続する。ブラウザから、Prometheus (`http://localhost:9090`) 、Kiali (`http://localhost:20001`) に接続する。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

12. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続する。

```bash:ターミナル
kubectl port-forward svc/istio-ingress-istio -n istio-ingress 9080:9080
```

## 掃除

1. Minikubeを削除する。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) をあらためて実施する。
