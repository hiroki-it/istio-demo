# 付録1

付録1では、Gateway APIとIstioの連携を学びます。

Istioのトラフィック管理系リソースの一部は、Gateway APIに置き換えられます。

ただし、Kialiではメッシュトポロジーを表示できなくなってしまうため、注意が必要です。

## セットアップ

1. Namespaceリソースを作成します。

```bash
kubectl apply -f chapter-extra-01/shared/namespace.yaml
```

2. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-extra-01/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-extra-01/istio/istio-istiod/helmfile.yaml apply
```

3. Istio IngressGatewayがデプロイされたままであれば、これを削除します。

```bash
helmfile -f chapter-extra-01/istio/istio-ingress/helmfile.yaml destroy
```

4. Gateway APIのカスタムリソース定義を作成します。

```bash
CRD_VERSION=1.2.0

kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml
```

5. Istioのトラフィック管理系リソースをGateway APIリソースに置き換えます。

```bash
helmfile -f chapter-extra-01/gateway/istio/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-extra-01/bookinfo-app/reviews/helmfile.yaml apply
```

6. `http://localhost:9080`から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/ingress-istio -n istio-ingress 9080:9080
```

7. `http://localhost:20001`から、Kialiのダッシュボードに接続します。メッシュトポロジーは表示できなくなっているはずです。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```
