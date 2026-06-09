#!/bin/bash

set -e

echo "Starting setup for Chapter 8..."

# MySQL コンテナの作成
echo "Deploying MySQL container..."
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Deploying Namespace..."
kubectl apply --server-side -f chapter-08/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Istiod コントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-08/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-08/istio/istio-istiod/helmfile.yaml apply

# Istio IngressGateway の作成
echo "Deploying Istio IngressGateway..."
helmfile -f chapter-08/istio/istio-ingress/helmfile.yaml apply

# Istio EgressGateway の作成
echo "Deploying Istio EgressGateway..."
helmfile -f chapter-08/istio/istio-egress/helmfile.yaml apply

# Istio リソースの作成
echo "Deploying Istio resources..."
helmfile -f chapter-08/bookinfo-app/mysql-istio/helmfile.yaml apply
helmfile -f chapter-08/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-08/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-08/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-08/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-08/bookinfo-app/reviews-istio/helmfile.yaml apply
helmfile -f chapter-08/bookinfo-app/share-istio/helmfile.yaml apply

# Kubernetes Pod のロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

# Keycloak の作成
echo "Deploying Keycloak..."
helmfile -f chapter-08/keycloak/helmfile.yaml apply

# Prometheus の作成
echo "Deploying Prometheus..."
helmfile -f chapter-08/prometheus/helmfile.yaml apply

# metrics-server の作成
echo "Deploying metrics-server..."
helmfile -f chapter-08/metrics-server/helmfile.yaml apply

# Grafana の作成
echo "Deploying Grafana..."
helmfile -f chapter-08/grafana/grafana/helmfile.yaml apply

# Kiali の作成
echo "Deploying Kiali..."
helmfile -f chapter-08/kiali/helmfile.yaml apply

# Minio の作成
echo "Deploying Minio..."
helmfile -f chapter-08/minio/helmfile.yaml apply

# Grafana Loki の作成
echo "Deploying Grafana Loki..."
helmfile -f chapter-08/grafana/grafana-loki/helmfile.yaml apply

# Grafana Alloy の作成
echo "Deploying Grafana Alloy..."
helmfile -f chapter-08/grafana/grafana-alloy/helmfile.yaml apply

# Grafana Tempo の作成
echo "Deploying Grafana Tempo..."
helmfile -f chapter-08/grafana/grafana-tempo/helmfile.yaml apply

# OpenTelemetry Collector の作成
echo "Deploying OpenTelemetry Collector..."
helmfile -f chapter-08/opentelemetry-collector/helmfile.yaml apply

echo "Setup Chapter 8 completed successfully!"
exit 0
