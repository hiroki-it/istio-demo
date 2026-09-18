#!/bin/bash

set -e

echo "付録のセットアップを開始します"

# MySQL コンテナの作成
echo "MySQL コンテナを作成します"
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Namespace を作成します"
kubectl apply --server-side -f chapter-extra/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Bookinfo アプリケーションを作成します"
helmfile -f bookinfo-app/details-app/helmfile.yaml apply
helmfile -f bookinfo-app/productpage-app/helmfile.yaml apply --set env.loggedIn=true
helmfile -f bookinfo-app/ratings-app/helmfile.yaml apply
helmfile -f bookinfo-app/reviews-app/helmfile.yaml apply

# Istiod コントロールプレーンの作成
echo "Istiod コントロールプレーンを作成します"
helmfile -f chapter-extra/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-extra/istio/istio-istiod/helmfile.yaml apply

# Gateway API のカスタムリソース定義の作成
echo "Gateway API の CRD を作成します"
CRD_VERSION=1.5.1
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v${CRD_VERSION}/standard-install.yaml

# Istio IngressGateway の作成
echo "Istio Ingress Gateway を作成します"
helmfile -f chapter-extra/istio/istio-ingress/helmfile.yaml apply

# Istio EgressGateway の作成
echo "Istio Egress Gateway を作成します"
helmfile -f chapter-extra/istio/istio-egress/helmfile.yaml apply

# Istio リソースの作成
echo "Istio リソースを作成します"
helmfile -f chapter-extra/bookinfo-app/mysql-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-extra/bookinfo-app/reviews-istio/helmfile.yaml apply

# Kubernetes Pod のロールアウト
echo "Kubernetes Pod を再起動します"
kubectl rollout restart deployment -n bookinfo

# Prometheus の作成
echo "Prometheus を作成します"
helmfile -f chapter-extra/prometheus/helmfile.yaml apply

# Grafana の作成
echo "Grafana を作成します"
helmfile -f chapter-extra/grafana/grafana/helmfile.yaml apply

# Kiali の作成
echo "Kiali を作成します"
helmfile -f chapter-extra/kiali/helmfile.yaml apply

echo "付録のセットアップが完了しました！"
exit 0
