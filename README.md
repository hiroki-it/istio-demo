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

1. Docker Desktopの [リソース設定](https://docs.docker.com/desktop/settings-and-maintenance/settings/#resources) から、ハードウェアリソースの上限を変更してください。CPUを`4`コア、メモリを`8`GB以上にしてください。

2. Minikubeを使用して、Kubernetesクラスターを作成します。

```bash
# バージョン
KUBERNETES_VERSION=1.32.3

# コントロールプレーンを含むNode数
NODE_COUNT=10

# ハードウェアリソース
CPU=4
MEMORY=7168

minikube start \
  --ha \
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

3. ワーカーNodeにNodeグループを表すラベルを設定します。

```bash
# istio-demo-m04 (app Node 1)
kubectl label node istio-demo-m04 node.kubernetes.io/nodegroup=app --overwrite \
  && kubectl label node istio-demo-m04 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m05 (app Node 2)
kubectl label node istio-demo-m05 node.kubernetes.io/nodegroup=app --overwrite \
  && kubectl label node istio-demo-m05 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m06 (app Node 3)
kubectl label node istio-demo-m06 node.kubernetes.io/nodegroup=app --overwrite \
  && kubectl label node istio-demo-m06 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m07 (ingress Node)
kubectl label node istio-demo-m07 node.kubernetes.io/nodegroup=ingress --overwrite \
  && kubectl label node istio-demo-m07 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m08 (egress Node)
kubectl label node istio-demo-m08 node.kubernetes.io/nodegroup=egress --overwrite \
  && kubectl label node istio-demo-m08 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m09 (system Node 1)
kubectl label node istio-demo-m09 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node istio-demo-m09 node-role.kubernetes.io/worker=worker --overwrite

# istio-demo-m10 (system Node 2)
kubectl label node istio-demo-m10 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node istio-demo-m10 node-role.kubernetes.io/worker=worker --overwrite
```

4. Nodeを確認します。

```bash
kubectl get nodes -L node.kubernetes.io/nodegroup

NAME             STATUS   ROLES           AGE     VERSION   NODEGROUP
istio-demo       Ready    control-plane   3m26s   v1.32.3   
istio-demo-m02   Ready    control-plane   3m12s   v1.32.3   
istio-demo-m03   Ready    control-plane   2m58s   v1.32.3   
istio-demo-m04   Ready    worker          2m44s   v1.32.3   app
istio-demo-m05   Ready    worker          2m31s   v1.32.3   app
istio-demo-m06   Ready    worker          2m16s   v1.32.3   app
istio-demo-m07   Ready    worker          2m1s    v1.32.3   ingress
istio-demo-m08   Ready    worker          106s    v1.32.3   egress
istio-demo-m09   Ready    worker          93s     v1.32.3   system
istio-demo-m10   Ready    worker          76s     v1.32.3   system
```
