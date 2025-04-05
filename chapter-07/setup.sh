#!/bin/bash

# filepath: /Users/hiroki-hasegawa/GitHub/hiroki-hasegawa/istio-demo/chapter-07/setup.sh

set -e

echo "Starting setup for Chapter 8..."

# 1. MySQLコンテナの作成
echo "Creating MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# 2. Namespaceの作成
echo "Creating Namespace..."
kubectl apply --server-side -f chapter-07/shared/namespace.yaml

# 3. Bookinfoアプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# 4. Istiodコントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-07/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-07/istio/istio-istiod/helmfile.yaml apply

# 5. Istio IngressGatewayの作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-07/istio/istio-ingress/helmfile.yaml apply

# 6. Istio EgressGatewayの作成
echo "Deploying Istio EgressGateway..."
helmfile -f chapter-07/istio/istio-egress/helmfile.yaml apply

# 7. Istioのトラフィック管理系リソースの作成
echo "Creating Istio traffic management resources..."
helmfile -f chapter-07/bookinfo-app/database-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/reviews-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/share-istio/helmfile.yaml apply

# 8. Kubernetes Podのロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# 9. Keycloakの作成
echo "Deploying Keycloak..."
helmfile -f chapter-07/keycloak/helmfile.yaml apply

# 10. Prometheusの作成
echo "Deploying Prometheus..."
helmfile -f chapter-07/prometheus/helmfile.yaml apply

# 11. metrics-serverの作成
echo "Deploying metrics-server..."
helmfile -f chapter-07/metrics-server/helmfile.yaml apply

# 12. Grafanaの作成
echo "Deploying Grafana..."
helmfile -f chapter-07/grafana/grafana/helmfile.yaml apply

# 13. Kialiの作成
echo "Deploying Kiali..."
helmfile -f chapter-07/kiali/helmfile.yaml apply

echo "Setup completed successfully!"