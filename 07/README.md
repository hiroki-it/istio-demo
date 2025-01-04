# 6章

6章では、Istioのセキュリティを学びます。

1. サービスメッシュ外にMySQLコンテナを作成します。`3306`番ポートが重複するため、`ratings-mysql`コンテナを停止しておきます。

```bash
docker container stop ratings-mysql

docker compose -f 07/keycloak/docker-compose.yaml up -d
```

2. Namespaceをデプロイします。

```bash
kubectl apply --server-side -f 07/shared/namespace.yaml
```

3. PeerAuthenticationをデプロイし、Namespaceの相互TLSを有効化します。

```bash
kubectl apply --server-side -f 07/shared/peer-authentication.yaml
```

4. Keycloakをデプロイします。

```bash
helmfile -f 07/keycloak/helmfile.yaml apply
```

5. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 07/bookinfo-app/details/helmfile.yaml apply

helmfile -f 07/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 07/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f 07/bookinfo-app/reviews/helmfile.yaml apply
```
