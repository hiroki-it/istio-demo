# 11章

以下を実践することにより、Istioアンビエントモードによるマイクロサービスの横断的管理を学びます。

- Istioコントロールプレーン、Istio IngressGateway、Istio waypoint-proxy、およびIstio CNI、Istio Ztunnelを導入する
- Istioのトラフィック管理系リソース (DestinationRule、Gateway、VirtualService) を作成する

## セットアップ

1. Namespaceを作成します。`.metadata`キーにアンビエントメッシュに管理下を表すラベルを設定しています。

```bash
kubectl apply -f chapter-11/shared/namespace.yaml
```

2. Bookinfoアプリケーションを作成します。

```bash
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

3. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-11/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-11/istio/istio-istiod/helmfile.yaml apply
```

4. Istio Ztunnelを作成します。これにより、Podに対するL4をトラフィックを管理できるようになります。

```bash
helmfile -f chapter-11/istio/istio-ztunnel/helmfile.yaml apply

helmfile -f chapter-11/istio/istio-cni/helmfile.yaml apply
```

5. Gateway APIのカスタムリソース定義とIstio Waypointを作成します。これにより、Podに対するL7のトラフィックを管理できるようになります。

```bash
CRD_VERSION=1.2.0

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml

helmfile -f chapter-11/istio/istio-waypoint-proxy/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-11/istio/istio-ingress/helmfile.yaml apply
```

7. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-11/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-11/bookinfo-app/reviews-istio/helmfile.yaml apply
```

8. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n bookinfo
```

9. Prometheusを作成します。

```bash
helmfile -f chapter-11/prometheus/helmfile.yaml apply
```

10. metrics-serverを作成します。

```bash
helmfile -f chapter-11/metrics-server/helmfile.yaml apply
```

11. Grafanaを作成します。

```bash
helmfile -f chapter-11/grafana/grafana/helmfile.yaml apply
```

12. Kialiを作成します。

```bash
helmfile -f chapter-11/kiali/helmfile.yaml apply
```

13. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

14. `http://localhost:20001`から、Kialiのダッシュボードに接続します。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

15. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

![bookinfo_productpage](../images/bookinfo_productpage.png)

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

```bash
minikube delete --profile istio-demo
```
