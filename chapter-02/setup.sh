#!/bin/bash

set -e

echo "Starting setup for Chapter 2..."

# MySQLコンテナの作成
echo "Creating MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespaceの作成
echo "Creating Namespace..."
kubectl apply --server-side -f chapter-02/shared/namespace.yaml

# Bookinfoアプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Istiodコントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-02/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-02/istio/istio-istiod/helmfile.yaml apply

# Istio IngressGatewayの作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-02/istio/istio-ingress/helmfile.yaml apply

# Istio EgressGatewayの作成
echo "Deploying Istio EgressGateway..."
helmfile -f chapter-02/istio/istio-egress/helmfile.yaml apply

# Istioのトラフィック管理系リソースの作成
echo "Creating Istio traffic management resources..."
helmfile -f chapter-02/bookinfo-app/database-istio/helmfile.yaml apply
helmfile -f chapter-02/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-02/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-02/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-02/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-02/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Podのロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheusの作成
echo "Deploying Prometheus..."
helmfile -f chapter-02/prometheus/helmfile.yaml apply

# Kialiの作成
echo "Deploying Kiali..."
helmfile -f chapter-02/kiali/helmfile.yaml apply

echo "Setup Chapter 2 completed successfully!"
exit 0