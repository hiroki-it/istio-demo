# 2章

2章では、マイクロサービスアーキテクチャにIstioを導入します。

## セットアップする

1. Namespaceリソースをデプロイします。

```bash
kubectl apply -f 02/shared/namespace.yaml
```

2. Istiodコントロールプレーンをデプロイします。

```bash
helmfile -f 02/istio/istio-base/helmfile.yaml apply

helmfile -f 02/istio/istio-istiod/helmfile.yaml apply
```

3. Istio IngressGatewayをデプロイします。

```bash
helmfile -f 02/istio/istio-ingress/helmfile.yaml apply
```

4. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 02/bookinfo-app/details/helmfile.yaml apply

helmfile -f 02/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 02/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f 02/bookinfo-app/reviews/helmfile.yaml apply
```

5. Kubernetes Namespaceのラベルに `istio.io/rev` を設定します。

```bash
kubectl label ns default istio.io/rev=stable
```

6. Kubernetes Podをロールアウトし、`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment
```

7. Istio IngressGatewayのNodePort Serviceを介して、Bookinfoアプリケーションに接続します。ブラウザから`9080`番ポートに接続してください。

```bash
kubectl port-forward svc/productpage 9080:9080
```

## 機能を実践する

## 掃除する
