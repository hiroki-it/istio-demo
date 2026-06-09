#!/bin/bash

set -e

echo "Starting setup for Chapter 11..."

# MySQL コンテナの作成
echo "Deploying MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Deploying Namespace..."
kubectl apply -f chapter-11/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply --set trafficManagement.enabled=true
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set env.loggedIn=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply --set trafficManagement.enabled=true

# Istiod コントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-11/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-11/istio/istio-istiod/helmfile.yaml apply

# Istio CNI の作成
echo "Deploying Istio CNI..."
helmfile -f chapter-11/istio/istio-cni/helmfile.yaml apply

# Istio Ztunnel の作成
echo "Deploying Istio Ztunnel..."
helmfile -f chapter-11/istio/istio-ztunnel/helmfile.yaml apply

# Gateway API のカスタムリソース定義と Istio Waypoint の作成
echo "Deploying Gateway API CRDs and Istio Waypoint..."
CRD_VERSION=1.5.1
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml
helmfile -f chapter-11/istio/istio-waypoint-proxy/helmfile.yaml apply

# Istio IngressGateway の作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-11/istio/istio-ingress/helmfile.yaml apply

# Istio EgressGateway の作成
echo "Deploying Istio EgressGateway..."
helmfile -f chapter-11/istio/istio-egress/helmfile.yaml apply

# Istio リソースの作成
echo "Deploying Istio resources..."
helmfile -f chapter-11/bookinfo-app/mysql-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-11/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Pod のロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Prometheus の作成
echo "Deploying Prometheus..."
helmfile -f chapter-11/prometheus/helmfile.yaml apply

# metrics-server の作成
echo "Deploying metrics-server..."
helmfile -f chapter-11/metrics-server/helmfile.yaml apply

# Grafana の作成
echo "Deploying Grafana..."
helmfile -f chapter-11/grafana/grafana/helmfile.yaml apply

# Kiali の作成
echo "Deploying Kiali..."
helmfile -f chapter-11/kiali/helmfile.yaml apply

echo "Setup Chapter 11 completed successfully!"
exit 0
