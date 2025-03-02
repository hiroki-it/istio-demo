# 付録2

付録2では、IstioサイドカーモードとGateway APIの統合を学びます。

Istioのトラフィック管理系リソースの一部は、Gateway APIリソースに置き換えられます。

ただし、以下の注意点があります。

- Gateway APIを適用したいNamespaceをサービスメッシュの管理下にする必要があります
- Gateway APIで代替できるIstioの機能は、執筆時点でトラフィック管理の一部のみです
- KialiはIstioのトラフィック系リソースのメトリクスに基づいてメッシュトポロジーを作成しているため、Kialiのダッシュボード上でメッシュトポロジーを確認できなくなります

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply -f chapter-extra-02/shared/namespace.yaml
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
helmfile -f chapter-extra-02/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-extra-02/istio/istio-istiod/helmfile.yaml apply
```

4. Istio IngressGatewayがあれば、これを削除します。

```bash
kubectl delete deployment istio-ingressgateway -n istio-ingress

kubectl delete service istio-ingressgateway -n istio-ingress
```

5. Gateway APIのカスタムリソース定義を作成します。

```bash
CRD_VERSION=1.2.0

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml
```

6. Istioのトラフィック管理系リソースをGateway APIリソースに置き換えます。

```bash
helmfile -f chapter-extra-02/istio/istio-ingress/helmfile.yaml apply

helmfile -f chapter-extra-02/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-extra-02/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-extra-02/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-extra-02/bookinfo-app/reviews-istio/helmfile.yaml apply
```

7. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n istio-system 9090:9090 & \
  kubectl port-forward svc/grafana -n istio-system 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

8. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/ingress-istio -n istio-ingress 9080:9080
```

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

```bash
minikube delete --profile istio-demo
```
