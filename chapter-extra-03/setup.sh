#!/bin/bash

set -e

echo "Starting setup for Appendix 3..."

# Namespaceの作成
echo "Creating Namespace..."
kubectl apply -f chapter-extra-03/shared/namespace.yaml

# Bookinfoアプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Istiodコントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-extra-03/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-extra-03/istio/istio-istiod/helmfile.yaml apply

# Istio IngressGatewayの作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-extra-03/istio/istio-ingress/helmfile.yaml apply

# Istioのトラフィック管理系リソースの作成
echo "Creating Istio traffic management resources..."
helmfile -f chapter-extra-03/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-extra-03/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-extra-03/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-extra-03/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Podのロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheusの作成
echo "Deploying Prometheus..."
helmfile -f chapter-extra-03/prometheus/helmfile.yaml apply

# metrics-serverの作成
echo "Deploying metrics-server..."
helmfile -f chapter-extra-03/metrics-server/helmfile.yaml apply

echo "Setup Extra 3 completed successfully!"
exit 0