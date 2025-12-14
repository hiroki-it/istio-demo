#!/bin/bash

set -e

echo "Starting setup for Appendix 2..."

# Namespaceの作成
echo "Creating Namespace..."
kubectl apply -f chapter-extra/shared/namespace.yaml

# Bookinfoアプリケーションの作成
echo "Deploying Bookinfo application..."
helmfile -f bookinfo-app/details/helmfile.yaml apply
helmfile -f bookinfo-app/productpage/helmfile.yaml apply --set loggedIn.enabled=true
helmfile -f bookinfo-app/ratings/helmfile.yaml apply
helmfile -f bookinfo-app/reviews/helmfile.yaml apply

# Istiodコントロールプレーンの作成
echo "Deploying Istiod control plane..."
helmfile -f chapter-extra/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-extra/istio/istio-istiod/helmfile.yaml apply

# Istio IngressGatewayの削除
echo "Deleting Istio IngressGateway..."
kubectl delete deployment istio-ingressgateway -n istio-ingress
kubectl delete service istio-ingressgateway -n istio-ingress

# Gateway APIのカスタムリソース定義の作成
echo "Creating Gateway API CRDs..."
CRD_VERSION=1.2.0
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml

# Istioのトラフィック管理系リソースをGateway APIリソースに置き換え
echo "Replacing Istio traffic management resources with Gateway API resources..."
helmfile -f chapter-extra/istio/istio-ingress/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Podのロールアウト
echo "Rolling out Kubernetes Pods..."
kubectl rollout restart deployment -n bookinfo

echo "Setup Extra 2 completed successfully!"
exit 0