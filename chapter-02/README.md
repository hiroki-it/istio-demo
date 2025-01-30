# 2章

2章では、マイクロサービスアプリケーションにIstioを導入します。

また同時に、KialiとPrometheusを導入します。

Kialiのメッシュトポロジーを確認し、Istioがマイクロサービス間にネットワークを作成する様子を確認します。

## セットアップ

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply -f chapter-02/shared/namespace.yaml
```

2. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-02/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-02/istio/istio-istiod/helmfile.yaml apply
```

3. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-02/istio/istio-ingress/helmfile.yaml apply
```

4. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-02/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-02/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-02/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-02/bookinfo-app/reviews/helmfile.yaml apply
```

6. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n app
```

7. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

8. Bookinfoアプリケーションに接続し、**Normal user**をクリックします。

![bookinfo](../images/bookinfo.png)

9. Productpageに接続します。

![bookinfo_productpage](../images/bookinfo_productpage.png)

10. Prometheusを作成します。

```bash
helmfile -f chapter-02/prometheus/helmfile.yaml apply
```

11. Kialiを作成します。

```bash
helmfile -f chapter-02/kiali/helmfile.yaml apply
```

12. Kialiのダッシュボードに接続します。ブラウザからPodの`20001`番ポートに接続してください。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

## 機能を実践する
