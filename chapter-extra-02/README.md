# 付録2

付録2では、Istioサイドカーモードとネイティブサイドカーの統合を学びます。

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

4. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-extra-02/istio/istio-ingress/helmfile.yaml apply
```

5. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-extra-02/bookinfo-app-istio/details/helmfile.yaml apply

helmfile -f chapter-extra-02/bookinfo-app-istio/productpage/helmfile.yaml apply

helmfile -f chapter-extra-02/bookinfo-app-istio/ratings/helmfile.yaml apply

helmfile -f chapter-extra-02/bookinfo-app-istio/reviews/helmfile.yaml apply
```

6. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n app
```

7. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

![bookinfo_productpage](../images/bookinfo_productpage.png)

8. Prometheusを作成します。

```bash
helmfile -f chapter-extra-02/prometheus/helmfile.yaml apply
```

9. Kialiを作成します。

```bash
helmfile -f chapter-extra-02/kiali/helmfile.yaml apply
```

10. `http://localhost:20001`から、Kialiのダッシュボードに接続します。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

```bash
minikube delete --profile istio-demo
```
