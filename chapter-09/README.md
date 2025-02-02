# 9章

9章では、Ambient Meshを検証します。

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply -f chapter-09/shared/namespace.yaml
```

2. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-09/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-09/istio/istio-istiod/helmfile.yaml apply
```

3. Istio Ztunnelを作成します。これにより、Podに対するL4をトラフィックを管理できるようになります。

```bash
helmfile -f chapter-09/istio/istio-ztunnel/helmfile.yaml apply

helmfile -f chapter-09/istio/istio-cni/helmfile.yaml apply
```

4. Gateway APIのカスタムリソース定義とIstio Waypointを作成します。これにより、Podに対するL7のトラフィックを管理できるようになります。

```bash
CRD_VERSION=1.2.0

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml

helmfile -f chapter-09/istio/istio-waypoint/helmfile.yaml apply
```

5. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-09/istio/istio-ingress/helmfile.yaml apply
```

6. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-09/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/reviews/helmfile.yaml apply
```

7. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n app
```

8. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

![bookinfo_productpage](../images/bookinfo_productpage.png)

9. Prometheusを作成します。

```bash
helmfile -f chapter-09/prometheus/helmfile.yaml apply
```

10. Kialiを作成します。

```bash
helmfile -f chapter-09/kiali/helmfile.yaml apply
```

11. `http://localhost:20001`から、Kialiのダッシュボードに接続します。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

## 機能を実践する
