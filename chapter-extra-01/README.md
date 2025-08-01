# 付録1

付録1では、Istioのアップグレードを学びます。

## セットアップ

### 事前準備

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash:ターミナル
kubectl apply -f chapter-extra-01/shared/namespace.yaml
```

2. Bookinfoアプリケーションを作成します。

```bash:ターミナル
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

3. Istiodコントロールプレーンを作成します。既存のIstiodコントロールプレーンは`blue`と表現することにします。

```bash:ターミナル
helmfile -f chapter-extra-01/istio/blue/istio-base/helmfile.yaml apply

helmfile -f chapter-extra-01/istio/blue/istio-istiod/helmfile.yaml apply
```

4. Istio IngressGatewayを作成します。

```bash:ターミナル
helmfile -f chapter-extra-01/istio/blue/istio-ingress/helmfile.yaml apply
```

5. Istioのトラフィック管理系リソースを作成します。

```bash:ターミナル
helmfile -f chapter-extra-01/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/reviews-istio/helmfile.yaml apply
```

6. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash:ターミナル
kubectl rollout restart deployment -n bookinfo
```

7. Prometheusを作成します。

```bash:ターミナル
helmfile -f chapter-extra-01/prometheus/helmfile.yaml apply
```

8. metrics-serverを作成します。

```bash:ターミナル
helmfile -f chapter-extra-01/metrics-server/helmfile.yaml apply
```

9. Grafanaを作成します。

```bash:ターミナル
helmfile -f chapter-extra-01/grafana/helmfile.yaml apply
```

10. Kialiを作成します。

```bash:ターミナル
helmfile -f chapter-extra-01/kiali/helmfile.yaml apply
```

11. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash:ターミナル
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

12. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash:ターミナル
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

### アップグレードする

## 実践する（詳しくは本書を参照）

## 掃除

1. Minikubeを削除します。

```bash:ターミナル
minikube delete --profile istio-demo
```

2. 他の章を実践する前に、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。
