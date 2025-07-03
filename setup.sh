#!/bin/bash

set -e

echo "Trusting mise..."
mise trust -a

echo "Installing mise..."
mise install

echo "Starting minikube..."

# バージョン
KUBERNETES_VERSION=1.32.0

# コントロールプレーンを含むNode数
NODE_COUNT=8

# 6コア
CPU=6

# 10GiB
MEMORY=12288

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

echo "Labeling node ..."

# ワーカーNodeにラベルを設定
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

# istio-demo-m08 (system Node 3)
kubectl label node istio-demo-m08 node.kubernetes.io/nodegroup=system --overwrite \
  && kubectl label node istio-demo-m08 node-role.kubernetes.io/worker=worker --overwrite

echo "Getting nodes..."
# Nodeの確認
kubectl get nodes -L node.kubernetes.io/nodegroup

echo "Setup minikube completed successfully!"
exit 0