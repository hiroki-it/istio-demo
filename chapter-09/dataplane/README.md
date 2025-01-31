# 9章：データプレーン

## セットアップ

1. Isitoデータプレーンを置くMinikubeクラスターを起動します

```bash
# バージョン
KUBERNETES_VERSION=1.32.0

# Node数
NODE_COUNT=3

# ハードウェアリソース
CPU=2
MEMORY=1024

minikube start \
  --profile istio-dataplane \
  --nodes ${NODE_COUNT} \
  --container-runtime containerd \
  --driver docker \
  --mount true \
  --mount-string "$(dirname $(pwd))/istio-dataplane:/data" \
  --kubernetes-version v${KUBERNETES_VERSION} \
  --cpus ${CPU} \
  --memory ${MEMORY} \
  --network multi-cluster
```

2. 現在のコンテキストが`istio-dataplane`になっていることを確認します。

```bash
kubectl config current-context
```

3. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-09/dataplane/istio/istio-ingress/helmfile.yaml apply
```

4. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-09/dataplane/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-09/dataplane/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-09/dataplane/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-09/dataplane/bookinfo-app/reviews/helmfile.yaml apply
```

5. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n app
```

6. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 9080:9080
```

![bookinfo_productpage](../images/bookinfo_productpage.png)
