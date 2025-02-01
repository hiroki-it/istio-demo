# 付録1

付録1では、Gateway APIとIstioの連携を学びます。

Istioのトラフィック管理系リソースの一部は、Gateway APIリソースに置き換えられます。

注意点として、Gateway APIを適用したいNamespaceをサービスメッシュの管理下にする必要があります。

また、KialiはIstioのトラフィック系リソースの情報に基づいてメッシュトポロジーを作成しているため、Kialiのダッシュボード上でメッシュトポロジーを確認できなくなります。

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply -f chapter-extra-01/shared/namespace.yaml
```

2. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-extra-01/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-extra-01/istio/istio-istiod/helmfile.yaml apply
```

3. Istio IngressGatewayがあれば、これを削除します。

```bash
kubectl delete deployment istio-ingressgateway -n istio-ingress

kubectl delete service istio-ingressgateway -n istio-ingress
```

4. Gateway APIのカスタムリソース定義を作成します。

```bash
CRD_VERSION=1.2.0

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml
```

5. Istioのトラフィック管理系リソースをGateway APIリソースに置き換えます。

```bash
helmfile -f chapter-extra-01/ingress/istio/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/reviews/helmfile.yaml apply
```

6. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/ingress-istio -n istio-ingress 9080:9080
```

7. `http://localhost:20001`から、Kialiのダッシュボードに接続します。メッシュトポロジーは表示できなくなっているはずです。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```
