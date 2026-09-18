#!/bin/bash

set -e

echo "まえがき 〜サンプルプロダクトを Istio なしで使ってみよう〜 のセットアップを開始します"

# MySQL コンテナの作成
echo "MySQL コンテナを作成します"
docker compose -f databases/docker-compose.yaml up -d

# Namespace の作成
echo "Namespace を作成します"
kubectl apply --server-side -f chapter-00/shared/namespace.yaml

# Bookinfo アプリケーションの作成
echo "Bookinfo アプリケーションを作成します"
helmfile -f bookinfo-app/details-app/helmfile.yaml apply
helmfile -f bookinfo-app/productpage-app/helmfile.yaml apply --set env.loggedIn=true
helmfile -f bookinfo-app/ratings-app/helmfile.yaml apply
helmfile -f bookinfo-app/reviews-app/helmfile.yaml apply

# Nginx Gateway Controller の作成
echo "Nginx Gateway Controller を作成します"
helmfile -f chapter-00/nginx/helmfile.yaml apply

# HTTPRoute の作成
echo "HTTPRoute を作成します"
helmfile -f chapter-00/bookinfo-app/productpage-istio/helmfile.yaml apply

# Prometheus の作成
echo "Prometheus を作成します"
helmfile -f chapter-00/prometheus/helmfile.yaml apply

echo "まえがき 〜サンプルプロダクトを Istio なしで使ってみよう〜 のセットアップが完了しました！"
exit 0
