# 2章

2章では、マイクロサービスアーキテクチャにIstioを導入します。

## Istioを構築する

1. Istioの構築に必要なリソースを事前に準備します。

```bash
kubectl apply -f 02/k8s-manifests/namespace.yaml

helmfile -f 02/istio/base/helmfile.yaml apply
```

2. Istiodコントロールプレーンをデプロイします。

```bash
helmfile -f 02/istio/istio-istiod/helmfile.yaml apply
```

3. Istio IngressGatewayをデプロイします。

```bash
helmfile -f 02/istio/istio-ingress/helmfile.yaml apply
```

## 各マイクロサービスをサービスメッシュの管理下にする

4. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 02/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 02/bookinfo-app/reviews/helmfile.yaml apply

helmfile -f 02/bookinfo-app/details/helmfile.yaml apply

helmfile -f 02/bookinfo-app/ratings/helmfile.yaml apply
```

5. Kubernetes Namespaceのラベルに `istio.io/rev` を設定します。

```bash
kubectl label ns default istio.io/rev=stable
```

6. Kubernetes Podをロールアウトし、`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment
```

7. Istio IngressGatewayのNodePort Serviceを介して、Bookinfoアプリケーションに接続します。ローカルホストでポート番号が発行されるため、ブラウザから接続してください。

```bash
minikube service istio-ingressgateway --url -n istio-ingress

http://127.0.0.1:<発行されたポート番号>
```
