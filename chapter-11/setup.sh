#!/bin/bash

set -e

echo "Starting setup for Chapter 11..."

# Namespaceの作成
echo "Creating Namespace..."
kubectl apply -f chapter-11/shared/namespace.yaml

# Bookinfoアプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Istiodコントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-11/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-11/istio/istio-istiod/helmfile.yaml apply

# Istio Ztunnelの作成
echo "Deploying Istio Ztunnel..."
helmfile -f chapter-11/istio/istio-ztunnel/helmfile.yaml apply
helmfile -f chapter-11/istio/istio-cni/helmfile.yaml apply

# Gateway APIのカスタムリソース定義とIstio Waypointの作成
echo "Creating Gateway API CRDs and Istio Waypoint..."
CRD_VERSION=1.2.0
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml
helmfile -f chapter-11/istio/istio-waypoint-proxy/helmfile.yaml apply

# Istio IngressGatewayの作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-11/istio/istio-ingress/helmfile.yaml apply

# Istioのトラフィック管理系リソースの作成
echo "Creating Istio traffic management resources..."
helmfile -f chapter-11/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/reviews-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/share-istio/helmfile.yaml apply

# Kubernetes Podのロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheusの作成
echo "Deploying Prometheus..."
helmfile -f chapter-11/prometheus/helmfile.yaml apply

# metrics-serverの作成
echo "Deploying metrics-server..."
helmfile -f chapter-11/metrics-server/helmfile.yaml apply

# Grafanaの作成
echo "Deploying Grafana..."
helmfile -f chapter-11/grafana/grafana/helmfile.yaml apply

# Kialiの作成
echo "Deploying Kiali..."
helmfile -f chapter-11/kiali/helmfile.yaml apply

echo "Setup Chapter 11 completed successfully!"
exit 0