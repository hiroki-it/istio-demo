# istio-demo

## プロジェクトについて

Bookinfoアプリケーションを使用して、Istioをデモンストレーションします。

![mesh-topology](./images/mesh-topology.png)

## 始める

### 前提

1. 以下をインストールします。

- [mise](https://mise.jdx.dev/getting-started.html)
- [Docker Desktop](https://docs.docker.com/desktop/)

2. miseを使用して、そのほかに必要なツールをインストールします。

```bash
$ mise trust

$ mise install
```

### Kubernetesクラスターのセットアップ

1. Docker Desktopの [リソース設定](https://docs.docker.com/desktop/settings-and-maintenance/settings/#resources) から、ハードウェアリソースの上限を変更してください。CPUを`5`、メモリを`10`以上にしてください。

2. Minikubeを使用して、Kubernetesクラスターを作成します。

```bash
# バージョン
KUBERNETES_VERSION=1.32.0

# Node数
NODE_COUNT=7

# ハードウェアリソース
CPU=4
MEMORY=8960

minikube start \
  --profile istio-demo \
  --nodes ${NODE_COUNT} \
  --container-runtime containerd \
  --driver docker \
  --mount true \
  --mount-string "$(dirname $(pwd))/istio-demo:/data" \
  --kubernetes-version v${KUBERNETES_VERSION} \
  --cpus ${CPU} \
  --memory ${MEMORY}
```

3. ワーカーNodeにラベルを設定します。

```bash
# istio-demo-m02 (app Node 1)
kubectl label node istio-demo-m02 node.kubernetes.io/nodegroup=app --overwrite \
  && kubectl label node istio-demo-m02 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m03 (app Node 2)
kubectl label node istio-demo-m03 node.kubernetes.io/nodegroup=app --overwrite \
  && kubectl label node istio-demo-m03 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m04 (ingress Node)
kubectl label node istio-demo-m04 node.kubernetes.io/nodegroup=ingress --overwrite \
  && kubectl label node istio-demo-m04 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m05 (egress Node)
kubectl label node istio-demo-m05 node.kubernetes.io/nodegroup=egress --overwrite \
  && kubectl label node istio-demo-m05 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m06 (system Node 1)
kubectl label node istio-demo-m06 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node istio-demo-m06 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m07 (system Node 2)
kubectl label node istio-demo-m07 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node istio-demo-m07 node-role.kubernetes.io/worker=worker --overwrite
```

4. Nodeを確認します。

```bash
kubectl get nodes -L node.kubernetes.io/nodegroup

NAME             STATUS   ROLES           AGE   VERSION   NODEGROUP
istio-demo       Ready    control-plane   13d   v1.32.0
istio-demo-m02   Ready    worker          13d   v1.32.0   app
istio-demo-m03   Ready    worker          13d   v1.32.0   ingress
istio-demo-m04   Ready    worker          13d   v1.32.0   egress
istio-demo-m05   Ready    worker          13d   v1.32.0   system
istio-demo-m06   Ready    worker          13d   v1.32.0   system
```
