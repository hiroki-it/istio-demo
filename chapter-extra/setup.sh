#!/bin/bash

set -e

echo "Starting setup for Chapter Extra..."

# MySQL コンテナの作成
echo "Deploying MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Deploying Namespace..."
kubectl apply --server-side -f chapter-extra/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Istiod コントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-extra/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-extra/istio/istio-istiod/helmfile.yaml apply

# Gateway API のカスタムリソース定義の作成
echo "Deploying Gateway API CRDs..."
CRD_VERSION=1.5.1
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml

# Istio IngressGateway の作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-extra/istio/istio-ingress/helmfile.yaml apply

# Istio EgressGateway の作成
echo "Deploying Istio EgressGateway..."
helmfile -f chapter-extra/istio/istio-egress/helmfile.yaml apply

# Istio リソースの作成
echo "Deploying Istio resources..."
helmfile -f chapter-extra/bookinfo-app/mysql-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Pod のロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheus の作成
echo "Deploying Prometheus..."
helmfile -f chapter-extra/prometheus/helmfile.yaml apply

# Grafana の作成
echo "Deploying Grafana..."
helmfile -f chapter-extra/grafana/grafana/helmfile.yaml apply

# Kiali の作成
echo "Deploying Kiali..."
helmfile -f chapter-extra/kiali/helmfile.yaml apply

echo "Setup Chapter Extra completed successfully!"
exit 0
