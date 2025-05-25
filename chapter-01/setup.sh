#!/bin/bash

set -e

echo "Starting setup for Chapter 1..."

# MySQLコンテナの作成
echo "Creating MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespaceの作成
echo "Creating Namespace..."
kubectl apply --server-side -f chapter-01/shared/namespace.yaml

# Bookinfoアプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Ingressの作成
echo "Creating Ingress..."
helmfile -f chapter-01/ingress/productpage/helmfile.yaml apply

# Nginx Ingress Controllerの作成
echo "Deploying Nginx Ingress Controller..."
helmfile -f chapter-01/nginx/helmfile.yaml apply

# Prometheusの作成
echo "Deploying Prometheus..."
helmfile -f chapter-01/prometheus/helmfile.yaml apply

echo "Setup Chapter 1 completed successfully!"
exit 0