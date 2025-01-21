# istio-demo

## プロジェクトについて

Bookinfoアプリを使用して、Istioをデモンストレーションします。

![mesh-topology](./images/mesh-topology.png)

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
# minikube-m02 (app Node)
kubectl label node minikube-m02 node.kubernetes.io/nodegroup=app --overwrite \
  && kubectl label node minikube-m02 node-role.kubernetes.io/worker=worker --overwrite

# minikube-m03 (ingress Node)
kubectl label node minikube-m03 node.kubernetes.io/nodegroup=ingress --overwrite \
  && kubectl label node minikube-m03 node-role.kubernetes.io/worker=worker --overwrite

# minikube-m04 (egress Node)
kubectl label node minikube-m04 node.kubernetes.io/nodegroup=egress --overwrite \
  && kubectl label node minikube-m04 node-role.kubernetes.io/worker=worker --overwrite

# minikube-m05 (system Node 1)
kubectl label node minikube-m05 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node minikube-m05 node-role.kubernetes.io/worker=worker --overwrite

# minikube-m06 (system Node 2)
kubectl label node minikube-m06 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node minikube-m06 node-role.kubernetes.io/worker=worker --overwrite
```

3. Nodeを確認します。

```bash
kubectl get nodes -L node.kubernetes.io/nodegroup

NAME           STATUS   ROLES           AGE   VERSION   NODEGROUP
minikube       Ready    control-plane   13d   v1.32.0
minikube-m02   Ready    worker          13d   v1.32.0   app
minikube-m03   Ready    worker          13d   v1.32.0   ingress
minikube-m04   Ready    worker          13d   v1.32.0   egress
minikube-m05   Ready    worker          13d   v1.32.0   system
minikube-m06   Ready    worker          13d   v1.32.0   system
```

## Bookinfoアプリケーションのデプロイ

1. Namespaceをデプロイします。

```bash
kubectl apply --server-side -f 00/shared/namespace.yaml
```

2. Bookinfoアプリケーションをデプロイします。

```bash
helmfile -f 00/bookinfo-app/details/helmfile.yaml apply

helmfile -f 00/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 00/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f 00/bookinfo-app/reviews/helmfile.yaml apply
```

3. アプリケーションが正常に稼働していることを確認します。

```bash
kubectl get pod -n app

NAME                             READY   STATUS    RESTARTS   AGE
details-v1-54ffdd5947-cfxwj      1/1     Running   0          8m21s
productpage-v1-d49bb79b4-rt2jh   1/1     Running   0          8m21s
ratings-v1-856f65bcff-jtkkf      1/1     Running   0          8m21s
reviews-v1-848b8749df-7svtl      1/1     Running   0          8m21s
reviews-v2-5fdf9886c7-k9cks      1/1     Running   0          8m21s
reviews-v3-bb6b8ddc7-7jzc8       1/1     Running   0          8m21s
```

### 掃除

1. Minikubeを削除します。

```bash
minikube delete --profile istio-demo
```
