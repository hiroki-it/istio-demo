# 9章：コントロールプレーン

## セットアップ

1. Minikubeクラスター間を接続するネットワークを作成します。

```bash
docker network create multi-cluster
```

2. Isitoコントロールプレーンを置くMinikubeクラスターを起動します

```bash
# バージョン
KUBERNETES_VERSION=1.32.0

# Node数
NODE_COUNT=2

# ハードウェアリソース
CPU=2
MEMORY=1024

minikube start \
  --profile istio-controlplane \
  --nodes ${NODE_COUNT} \
  --container-runtime containerd \
  --driver docker \
  --mount true \
  --mount-string "$(dirname $(pwd))/istio-controlplane:/data" \
  --kubernetes-version v${KUBERNETES_VERSION} \
  --cpus ${CPU} \
  --memory ${MEMORY} \
  --network multi-cluster
```

3. 現在のコンテキストが`istio-controlplane`になっていることを確認します。

```bash
kubectl config current-context
```

4. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-09/controlplane/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-09/controlplane/istio/istio-istiod/helmfile.yaml apply
```

5. Prometheusを作成します。

```bash
helmfile -f chapter-02/prometheus/helmfile.yaml apply
```

6. Kialiを作成します。

```bash
helmfile -f chapter-02/kiali/helmfile.yaml apply
```

7. `http://localhost:20001`から、Kialiのダッシュボードに接続します。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```
