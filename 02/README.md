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

6. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n app
```

7. Istio IngressGatewayのNodePort Serviceを介して、Bookinfoアプリケーションに接続します。ブラウザから発行されたURLに接続してください。

```bash
minikube service istio-ingressgateway -n istio-ingress --url
```

8. Bookinfoアプリケーションに接続し、**Normal user**をクリックします。

![bookinfo](../images/bookinfo.png)

9. Productpageに接続します。

![bookinfo_productpage](../images/bookinfo_productpage.png)

## 機能を実践する
