# 6章

## セットアップ

6章では、Istioのセキュリティを学びます。

1. サービスメッシュ外に、Keycloakサービス用のMySQLコンテナを作成します。これは、空の`keycloak`データベースを持ちます。

```bash
docker compose -f 07/keycloak/docker-compose.yaml up -d

docker exec -it keycloak-mysql /bin/sh
                                                                                                                                                                              (minikube/default)
sh-4.4# mysql -h localhost -u root -ppassword

mysql> SHOW TABLES FROM keycloak;
Empty set
```

2. Namespaceをデプロイします。

```bash
kubectl apply --server-side -f 07/shared/namespace.yaml
```

3. PeerAuthenticationをデプロイし、Namespaceの相互TLSを有効化します。

```bash
kubectl apply --server-side -f 07/shared/peer-authentication.yaml
```

4. Istio IngressGatewayをデプロイします。

```bash
helmfile -f 07/istio/istio-ingress/helmfile.yaml apply
```

5. Keycloakをデプロイします。

```bash
helmfile -f 07/keycloak/keycloakx/helmfile.yaml apply
```

6. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 07/bookinfo-app/details/helmfile.yaml apply

helmfile -f 07/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 07/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f 07/bookinfo-app/reviews/helmfile.yaml apply
```

7. Istio IngressGatewayのNodePort Serviceを介して、Keycloakに接続します。ブラウザから`8080`番ポートに接続してください。

```bash
kubectl port-forward svc/productpage 8080:8080
```
