# istio-demo

## プロジェクトについて

Bookinfoアプリを使用して、Istioをデモンストレーションします。

![mesh-topology](./images/mesh-topology.png)

## 始める

### 前提

以下をインストールします。

- [mise](https://mise.jdx.dev/getting-started.html)
- [Docker Desktop](https://docs.docker.com/desktop/)

### miseによるインストール

1. miseを使用して、そのほかに必要なツールをインストールします

```bash
$ mise trust

$ mise install
```

2. Helmプラグインをインストールします

```bash
$ helm plugin install https://github.com/databus23/helm-diff
```

### Minikubeのセットアップ

1. Minikubeを起動します

```bash
# バージョン
KUBERNETES_VERSION=1.32.0

# Node数
NODE_COUNT=6

# ハードウェアリソース
CPU=6
MEMORY=6144

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

2. ワーカーNodeにラベルを設定します。

```bash
# istio-demo-m02 (app Node)
kubectl label node istio-demo-m02 node.kubernetes.io/nodegroup=app --overwrite \
  && kubectl label node istio-demo-m02 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m03 (ingress Node)
kubectl label node istio-demo-m03 node.kubernetes.io/nodegroup=ingress --overwrite \
  && kubectl label node istio-demo-m03 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m04 (egress Node)
kubectl label node istio-demo-m04 node.kubernetes.io/nodegroup=egress --overwrite \
  && kubectl label node istio-demo-m04 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m05 (system Node 1)
kubectl label node istio-demo-m05 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node istio-demo-m05 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m06 (system Node 2)
kubectl label node istio-demo-m06 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node istio-demo-m06 node-role.kubernetes.io/worker=worker --overwrite
```

3. Nodeを確認します。

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

### 掃除

1. Minikubeを削除します。

```bash
minikube delete --profile istio-demo
```
