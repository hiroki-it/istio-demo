#!/bin/bash

set -e

echo "Starting setup for Appendix 1..."

# Namespaceの作成
echo "Creating Namespace..."
kubectl apply -f chapter-extra-01/shared/namespace.yaml

# Bookinfoアプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Istiodコントロールプレーンの作成
echo "Deploying Istiod control plane (blue)..."
helmfile -f chapter-extra-01/istio/blue/istio-base/helmfile.yaml apply
helmfile -f chapter-extra-01/istio/blue/istio-istiod/helmfile.yaml apply

# Istio IngressGatewayの作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-extra-01/istio/blue/istio-ingress/helmfile.yaml apply

# Istioのトラフィック管理系リソースの作成
echo "Creating Istio traffic management resources..."
helmfile -f chapter-extra-01/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-extra-01/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-extra-01/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-extra-01/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Podのロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheusの作成
echo "Deploying Prometheus..."
helmfile -f chapter-extra-01/prometheus/helmfile.yaml apply

# metrics-serverの作成
echo "Deploying metrics-server..."
helmfile -f chapter-extra-01/metrics-server/helmfile.yaml apply

# Grafanaの作成
echo "Deploying Grafana..."
helmfile -f chapter-extra-01/grafana/helmfile.yaml apply

# Kialiの作成
echo "Deploying Kiali..."
helmfile -f chapter-extra-01/kiali/helmfile.yaml apply

echo "Setup Extra 1 completed successfully!"
exit 0