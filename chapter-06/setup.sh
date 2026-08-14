#!/bin/bash

set -e

echo "Starting setup for Chapter 6..."

# MySQL コンテナの作成
echo "Deploying MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Deploying Namespace..."
kubectl apply --server-side -f chapter-06/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details-app/helmfile.yaml apply
helmfile -f bookinfo-app/productpage-app/helmfile.yaml apply --set env.loggedIn=true
helmfile -f bookinfo-app/ratings-app/helmfile.yaml apply
helmfile -f bookinfo-app/reviews-app/helmfile.yaml apply

# Istiod コントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-06/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-06/istio/istio-istiod/helmfile.yaml apply

# Istio IngressGateway の作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-06/istio/istio-ingress/helmfile.yaml apply

# Istio EgressGateway の作成
echo "Deploying Istio EgressGateway..."
helmfile -f chapter-06/istio/istio-egress/helmfile.yaml apply

# Istio の L4/L7 トラフィック管理系リソースの作成
echo "Deploying Istio traffic management resources..."
helmfile -f chapter-06/bookinfo-app/mysql-istio/helmfile.yaml apply
helmfile -f chapter-06/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-06/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-06/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-06/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-06/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Pod のロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheus の作成
echo "Deploying Prometheus..."
helmfile -f chapter-06/prometheus/helmfile.yaml apply

# metrics-server の作成
echo "Deploying metrics-server..."
helmfile -f chapter-06/metrics-server/helmfile.yaml apply

# Grafana の作成
echo "Deploying Grafana..."
helmfile -f chapter-06/grafana/grafana/helmfile.yaml apply

# Kiali の作成
echo "Deploying Kiali..."
helmfile -f chapter-06/kiali/helmfile.yaml apply

echo "Setup Chapter 6 completed successfully!"
exit 0
