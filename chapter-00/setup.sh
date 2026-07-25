#!/bin/bash

set -e

echo "Starting setup for Chapter 1..."

# MySQL コンテナの作成
echo "Deploying MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Deploying Namespace..."
kubectl apply --server-side -f chapter-00/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Nginx Gateway Controller の作成
echo "Deploying Nginx Gateway Controller..."
helmfile -f chapter-00/nginx/helmfile.yaml apply

# HTTPRoute の作成
echo "Deploying HTTPRoute..."
helmfile -f chapter-00/bookinfo-app/productpage-istio/helmfile.yaml apply

# Prometheus の作成
echo "Deploying Prometheus..."
helmfile -f chapter-00/prometheus/helmfile.yaml apply

echo "Setup Chapter 1 completed successfully!"
exit 0
