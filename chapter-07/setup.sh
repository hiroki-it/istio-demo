#!/bin/bash

set -e

echo "7章のセットアップを開始します"

# MySQL コンテナの作成
echo "MySQL コンテナを作成します"
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Namespace を作成します"
kubectl apply --server-side -f chapter-07/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Bookinfo アプリケーションを作成します"
helmfile -f bookinfo-app/details-app/helmfile.yaml apply
helmfile -f bookinfo-app/productpage-app/helmfile.yaml apply
helmfile -f bookinfo-app/ratings-app/helmfile.yaml apply
helmfile -f bookinfo-app/reviews-app/helmfile.yaml apply

# Istiod コントロールプレーンの作成
echo "Istiod コントロールプレーンを作成します"
helmfile -f chapter-07/istio/istio-base/helmfile.yaml apply
helmfile -f chapter-07/istio/istio-istiod/helmfile.yaml apply

# Istio IngressGateway の作成
echo "Istio Ingress Gateway を作成します"
helmfile -f chapter-07/istio/istio-ingress/helmfile.yaml apply

# Istio EgressGateway の作成
echo "Istio Egress Gateway を作成します"
helmfile -f chapter-07/istio/istio-egress/helmfile.yaml apply

# Istio リソースの作成
echo "Istio リソースを作成します"
helmfile -f chapter-07/bookinfo-app/mysql-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/details-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/googleapis-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/productpage-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/ratings-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/reviews-istio/helmfile.yaml apply
helmfile -f chapter-07/bookinfo-app/shared-istio/helmfile.yaml apply

# 8. Kubernetes Pod のロールアウト
echo "Kubernetes Pod を再起動します"
kubectl rollout restart deployment -n bookinfo

# 9. Keycloak の作成
echo "Keycloak を作成します"
helmfile -f chapter-07/keycloak/helmfile.yaml apply

# 10. Prometheus の作成
echo "Prometheus を作成します"
helmfile -f chapter-07/prometheus/helmfile.yaml apply

# 11. metrics-server の作成
echo "metrics-server を作成します"
helmfile -f chapter-07/metrics-server/helmfile.yaml apply

# 12. Grafana の作成
echo "Grafana を作成します"
helmfile -f chapter-07/grafana/grafana/helmfile.yaml apply

# 13. Kiali の作成
echo "Kiali を作成します"
helmfile -f chapter-07/kiali/helmfile.yaml apply

echo "7章のセットアップが完了しました！"
exit 0
