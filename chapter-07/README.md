# 7章

7章では、Istioによるセキュリティを学びます。

証明書管理系リソース (PeerAuthentication) と認証認可 (AuthorizationPolicy、RequestAuthentication) を使用して、Istioが証明書や認証認可を管理する様子を確認します。

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

1. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply --server-side -f chapter-07/shared/namespace.yaml
```

4. PeerAuthenticationを作成します。

```bash
kubectl apply --server-side -f chapter-07/shared/peer-authentication.yaml
```

5. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-07/istio/istio-ingress/helmfile.yaml apply
```

6. Istio EgressGatewayを作成します。

```bash
helmfile -f chapter-07/istio/istio-egress/helmfile.yaml apply
```

7. Keycloakを作成します。

```bash
helmfile -f chapter-07/keycloak/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-07/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-07/bookinfo-app/reviews/helmfile.yaml apply
```

9. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 8080:8080 9080:9080
```

10. 接続時点では未認証です。detailsサービスとreviewsサービスはproductpageサービスに `403` を返信するため、productpageサービスは詳細情報とレビュー情報を取得できず、ユーザーはこれらを閲覧できません。

12. Sign inボタンをクリックすると、productpageサービスはKeycloakに認可リクエストを送信します。 Keycloakは認証画面をレスポンスするため、ユーザー名を`izzy`、パスワードを`izzy`とします。Keycloakの認証に成功すれば、Keycloakに登録された`izzy`ユーザーでBookinfoにSSOできます。

13. 認証後、productpageサービスから後続のマイクロサービスにアクセストークンが伝播します。これにより、detailsサービスとreviewsサービスはproductpageサービスに `200` を返信します。productpageサービスは詳細情報とレビュー情報を取得できるようになり、ユーザーはこれらを閲覧できます。


## 機能を実践する
