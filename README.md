# istio-demo

## プロジェクトについて

Bookinfoアプリケーションを使用して、Istioをデモンストレーションする。

## 始める

### 前提

#### Mac

```bash
$ brew install asdf
```

### インストール

```bash
$ asdf plugin add helmfile
$ asdf plugin add istioctl
$ asdf plugin add kubectl
$ asdf plugin add minikube

$ asdf install
```

### Minikubeのセットアップ

1. Minikubeを起動する

```bash
# バージョン
$ KUBERNETES_VERSION=1.32.0

# パス
$ PROJECT_DIR=$(dirname $(pwd))

$ minikube start \
    --nodes 5 \
    --container-runtime=containerd \
    --driver=docker \
    --mount=true \
	--mount-string="${PROJECT_DIR}/istio-demo:/data" \
	--kubernetes-version=v${KUBERNETES_VERSION} \
	--cpus=8 \
	--memory=12288
```

2. ワーカーNodeにラベルを設定する

```bash
$ kubectl label node minikube-m02 node.kubernetes.io/nodegroup=app \
  && kubectl label node minikube-m04 node.kubernetes.io/nodegroup=ingress \
  && kubectl label node minikube-m04 node.kubernetes.io/nodegroup=egress \
  && kubectl label node minikube-m05 node.kubernetes.io/nodegroup=system
```
