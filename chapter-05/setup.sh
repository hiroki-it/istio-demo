#!/bin/bash

set -e

echo "Starting setup for Chapter 5..."

# MySQL コンテナの作成
echo "Deploying MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Deploying Namespace..."
kubectl apply --server-side -f chapter-05/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply --set trafficManagement.enabled=true
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply --set trafficManagement.enabled=true

# Istiod コントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-05/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-05/istio/istio-istiod/helmfile.yaml apply

# Istio IngressGateway の作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-05/istio/istio-ingress/helmfile.yaml apply

# Istio EgressGateway の作成
echo "Deploying Istio EgressGateway..."
helmfile -f chapter-05/istio/istio-egress/helmfile.yaml apply

# Istio リソースの作成
echo "Deploying Istio resources..."
helmfile -f chapter-05/bookinfo-app/mysql-istio/helmfile.yaml apply
helmfile -f chapter-05/bookinfo-app/details-istio/helmfile.only-v3.yaml apply
helmfile -f chapter-05/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-05/bookinfo-app/productpage-istio/helmfile.only-v2.yaml apply
helmfile -f chapter-05/bookinfo-app/ratings-istio/helmfile.only-v3.yaml apply
helmfile -f chapter-05/bookinfo-app/reviews-istio/helmfile.only-v4.yaml apply

# Kubernetes Pod のロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheus の作成
echo "Deploying Prometheus..."
helmfile -f chapter-05/prometheus/helmfile.yaml apply

# metrics-server の作成
echo "Deploying metrics-server..."
helmfile -f chapter-05/metrics-server/helmfile.yaml apply

# Grafana の作成
echo "Deploying Grafana..."
helmfile -f chapter-05/grafana/grafana/helmfile.yaml apply

# Kiali の作成
echo "Deploying Kiali..."
helmfile -f chapter-05/kiali/helmfile.yaml apply

echo "Setup Chapter 5 completed successfully!"
exit 0
