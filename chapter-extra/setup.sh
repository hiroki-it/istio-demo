#!/bin/bash

set -e

echo "Starting setup for Chapter Extra..."

# MySQLコンテナの作成
echo "Creating MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespaceの作成
echo "Creating Namespace..."
kubectl apply --server-side -f chapter-extra/shared/namespace.yaml

# Bookinfoアプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Istiodコントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-extra/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-extra/istio/istio-istiod/helmfile.yaml apply

# Gateway APIのカスタムリソース定義の作成
echo "Creating Gateway API CRDs..."
CRD_VERSION=1.3.0
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml

# Istio IngressGatewayの作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-extra/istio/istio-ingress/helmfile.yaml apply

# Istioリソースの作成
echo "Creating Istio resources..."
helmfile -f chapter-extra/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Podのロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheusの作成
echo "Deploying Prometheus..."
helmfile -f chapter-extra/prometheus/helmfile.yaml apply

# Kialiの作成
echo "Deploying Kiali..."
helmfile -f chapter-extra/kiali/helmfile.yaml apply

echo "Setup Chapter Extra completed successfully!"
exit 0
