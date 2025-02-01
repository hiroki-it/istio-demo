# 9章：コントロールプレーン

## セットアップ


2. Isitoコントロールプレーンを置くMinikubeクラスターを起動します

```bash
# バージョン
KUBERNETES_VERSION=1.32.0

# Node数
NODE_COUNT=2

# ハードウェアリソース
CPU=2
MEMORY=1800

minikube start \
  --profile istio-controlplane \
  --nodes ${NODE_COUNT} \
  --container-runtime containerd \
  --driver docker \
  --mount true \
  --mount-string "$(dirname $(pwd))/istio-controlplane:/data" \
  --kubernetes-version v${KUBERNETES_VERSION} \
  --cpus ${CPU} \
  --memory ${MEMORY}
```

```bash
kubectl label node istio-controlplane-m02 node-role.kubernetes.io/worker=worker --overwrite
```

3. 現在のコンテキストが`istio-controlplane`になっていることを確認します。

```bash
kubectl config current-context
```

```bash
kubectl apply -f chapter-09/controlplane/shared/namespace.yaml
```

4. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-09/controlplane/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-09/controlplane/istio/istio-istiod/helmfile.yaml apply
```

5. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-09/controlplane/istio/istio-ingress/helmfile.yaml apply
```

5. Prometheusを作成します。

```bash
helmfile -f chapter-09/prometheus/helmfile.yaml apply
```

6. Kialiを作成します。

```bash
helmfile -f chapter-09/kiali/helmfile.yaml apply
```

7. `http://localhost:20001`から、Kialiのダッシュボードに接続します。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```
