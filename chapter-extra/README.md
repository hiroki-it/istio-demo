# 付録

付録では、IstioサイドカーモードとGateway APIの統合を学びます。

Istioのトラフィック管理系リソースの一部は、Gateway APIリソースに置き換えられます。

ただし、以下の注意点があります。

- Gateway APIを適用したいNamespaceをサービスメッシュの管理下にする必要があります
- Gateway APIで代替できるIstioの機能は、執筆時点でトラフィック管理の一部のみです
- KialiはIstioのトラフィック系リソースのメトリクスに基づいてメッシュトポロジーを作成しているため、Kialiのダッシュボード上でメッシュトポロジーを確認できなくなります

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash:ターミナル
kubectl apply -f chapter-extra/shared/namespace.yaml
```

2. Bookinfoアプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

3. Istiodコントロールプレーンを作成します。

```bash:ターミナル
helmfile -f chapter-extra/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-extra/istio/istio-istiod/helmfile.yaml apply
```

4. Istio IngressGatewayがあれば、これを削除します。

```bash:ターミナル
kubectl delete deployment istio-ingressgateway -n istio-ingress

kubectl delete service istio-ingressgateway -n istio-ingress
```

5. Gateway APIのカスタムリソース定義を作成します。

```bash:ターミナル
CRD_VERSION=1.2.0

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml
```

6. Istioのトラフィック管理系リソースをGateway APIリソースに置き換えます。

```bash:ターミナル
helmfile -f chapter-extra/istio/istio-ingress/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-extra/bookinfo-app/reviews-istio/helmfile.yaml apply
```

7. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

8. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 3000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

9. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/ingress-istio -n istio-ingress 9080:9080
```

## 掃除

1. Minikubeを削除します。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. ほかの章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。
