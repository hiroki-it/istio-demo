# istio-demo

## プロジェクトについて

Bookinfoアプリを使用して、Istioをデモンストレーションします。

## 始める

### 前提

- [mise](https://mise.jdx.dev/getting-started.html) をインストールする
- [Docker Desktop](https://docs.docker.com/desktop/) をインストールする

### インストール

1. miseを使用して、必要なツールをインストールします

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
NODE_COUNT=5

# ハードウェアリソース
CPU=6
MEMORY=6144

minikube start \
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
kubectl label node minikube-m02 node.kubernetes.io/nodegroup=app --overwrite \
  && kubectl label node minikube-m03 node.kubernetes.io/nodegroup=ingress --overwrite \
  && kubectl label node minikube-m04 node.kubernetes.io/nodegroup=egress --overwrite \
  && kubectl label node minikube-m05 node.kubernetes.io/nodegroup=system --overwrite
```

3. Nodeを確認します。

```bash
kubectl get nodes
                                                                                                                                                         (minikube/default)
NAME           STATUS   ROLES           AGE    VERSION
minikube       Ready    control-plane   105s   v1.32.0
minikube-m02   Ready    <none>          93s    v1.32.0
minikube-m03   Ready    <none>          84s    v1.32.0
minikube-m04   Ready    <none>          71s    v1.32.0
minikube-m05   Ready    <none>          61s    v1.32.0
```

### 掃除

1. Minikubeを削除します。

```bash
minikube delete --all --purge
```
