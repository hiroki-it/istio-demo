# 7章

7章では、Istioによるセキュリティを学びます。

Istioカスタムリソース (AuthorizationPolicy、PeerAuthentication、RequestAuthentication) を使用して、Istioが証明書や認証認可を管理する様子を確認します。

## セットアップ


1. サービスメッシュ外に、Keycloakサービス用のMySQLコンテナを作成します。

```bash
docker compose -f chapter-07/keycloak/docker-compose.yaml up -d
```

2.`test`データベースに`rating`テーブルを持つことを確認します。

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

6. Istio EgressGatewayをデプロイします。

```bash
helmfile -f chapter-07/istio/istio-egress/helmfile.yaml apply
```

7. Keycloakをデプロイします。

```bash
helmfile -f chapter-07/keycloak/helmfile.yaml apply
```

8. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f chapter-07/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/reviews/helmfile.yaml apply
```

9. Istio IngressGatewayのNodePort Serviceを介して、Keycloakに接続します。ブラウザから、2つ目に発行されたURLに接続してください。なお、1つ目はproductpageのURLです。

```bash
minikube service istio-ingressgateway -n istio-ingress --profile istio-demo --url
```

## 機能を実践する

### アクセストークンの取得

ログインのリクエストを仮定して、アクセストークンを取得します。

```bash
HOST=http://localhost:64928

curl http://${HOST}/auth/realms/dev/protocol/openid-connect/auth?response_type=code&client_id=service&redirect_uri=http://keycloak-http.app.svc.cluster.local:8080/authentication/callback&scope=openid

curl ${HOST}/auth/realms/dev/protocol/openid-connect/token \
  -d "grant_type=authorization_code&code=4dd3788b-e8a4-4ad6-8f03-28fb68f266f7.052bddf1-8bbc-4d61-a61c-2497fe5b8210.033f1115-baf8-4ca6-87b4-5d2938bcc665&redirect_uri=http://keycloak-http.app.svc.cluster.local:8080/authentication/callback&client_id=service&client_secret=ZQBzxI5CU36UiQmrWtDbJkY3VOX5LJRY"
```
