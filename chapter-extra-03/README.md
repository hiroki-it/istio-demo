# 付録3

付録3では、Istioサイドカーモードとネイティブサイドカーの統合を学びます。

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply -f chapter-extra-03/shared/namespace.yaml
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
helmfile -f chapter-extra-03/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-extra-03/istio/istio-istiod/helmfile.yaml apply
```

4. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-extra-03/istio/istio-ingress/helmfile.yaml apply
```

5. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-extra-03/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-extra-03/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-extra-03/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-extra-03/bookinfo-app/reviews-istio/helmfile.yaml apply
```

6. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n bookinfo
```

7. Prometheusを作成します。

```bash
helmfile -f chapter-extra-03/prometheus/helmfile.yaml apply
```

8. metrics-serverを作成します。

```bash
helmfile -f chapter-extra-03/metrics-server/helmfile.yaml apply
```

9. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

10. `http://localhost:20001`から、Kialiのダッシュボードに接続します。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

11. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

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
