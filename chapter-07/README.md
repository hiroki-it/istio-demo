# 7章

## セットアップ

7章では、Istioのセキュリティを学びます。

1. サービスメッシュ外に、Keycloakサービス用のMySQLコンテナを作成します。

```bash
docker compose -f chapter-07/keycloak/docker-compose.yaml up -d
```

2.`keycloak`データベースはさまざまなテーブルを持つことを確認します。

```bash
docker exec -it keycloak-mysql /bin/sh

sh-4.4# mysql -h keycloak.mysql.dev -u keycloak -pkeycloak

mysql> SHOW TABLES FROM keycloak;
+-------------------------------+
| Tables_in_keycloak            |
+-------------------------------+
| ADMIN_EVENT_ENTITY            |
...
| WEB_ORIGINS                   |
+-------------------------------+
```

3. Namespaceリソースをデプロイします。

```bash
kubectl apply --server-side -f chapter-07/shared/namespace.yaml
```

4. PeerAuthenticationリソースをデプロイします。

```bash
kubectl apply --server-side -f chapter-07/shared/peer-authentication.yaml
```

5. Istio IngressGatewayをデプロイします。

```bash
helmfile -f chapter-07/istio/istio-ingress/helmfile.yaml apply
```

6. Keycloakをデプロイします。

```bash
helmfile -f chapter-07/keycloak/helmfile.yaml apply
```

7. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f chapter-07/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/reviews/helmfile.yaml apply
```

8. Istio IngressGatewayのNodePort Serviceを介して、Keycloakに接続します。ブラウザから発行されたURLに接続してください。

```bash
minikube service istio-ingressgateway -n istio-ingress --profile istio-demo --url
```
