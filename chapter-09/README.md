# 9章

以下を実践することにより、Istioサイドカーモードによる認証認可を学びます。

- Istioコントロールプレーン、Istio IngressGateway、およびIstio Egress Gatewayを導入する
- 認証認可系リソース (AuthorizationPolicy、RequestAuthentication) を作成します

## セットアップ

1. サービスメッシュ外に、MySQLコンテナを作成します。

```bash
docker compose -f databases/docker-compose.yaml up -d
```

2. `keycloak`と`test`というデータベースがあることを確認します。

```bash
docker exec -it istio-demo-mysql /bin/sh

sh-4.4# mysql -h dev.istio-demo-mysql -u root -proot

mysql> SHOW DATABASES;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| keycloak           |
| mysql              |
| performance_schema |
| sys                |
| test               |
+--------------------+
```

3. Namespaceを作成します。`.metadata`キーにサービスメッシュの管理下であるリビジョンラベルを設定しています。

```bash
kubectl apply --server-side -f chapter-09/shared/namespace.yaml
```

4. Bookinfoアプリケーションを作成します。

```bash
helmfile -f bookinfo-app/details/helmfile.yaml apply

helmfile -f bookinfo-app/productpage/helmfile.yaml apply

helmfile -f bookinfo-app/ratings/helmfile.yaml apply

helmfile -f bookinfo-app/reviews/helmfile.yaml apply
```

5. Istiodコントロールプレーンを作成します。

```bash
helmfile -f chapter-09/istio/istio-base/helmfile.yaml apply

helmfile -f chapter-09/istio/istio-istiod/helmfile.yaml apply
```

6. Istio IngressGatewayを作成します。

```bash
helmfile -f chapter-09/istio/istio-ingress/helmfile.yaml apply
```

7. Istio EgressGatewayを作成します。

```bash
helmfile -f chapter-09/istio/istio-egress/helmfile.yaml apply
```

8. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-09/bookinfo-app/database-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/details-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/googleapis-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/productpage-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/ratings-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/reviews-istio/helmfile.yaml apply

helmfile -f chapter-09/bookinfo-app/share-istio/helmfile.yaml apply
```

9. Kubernetes Podをロールアウトし、BookinfoアプリケーションのPodに`istio-proxy`をインジェクションします。

```bash
kubectl rollout restart deployment -n bookinfo
```

10. Keycloakを作成します。

```bash
helmfile -f chapter-09/keycloak/helmfile.yaml apply
```

11. Prometheusを作成します。

```bash
helmfile -f chapter-09/prometheus/helmfile.yaml apply
```

12. metrics-serverを作成します。

```bash
helmfile -f chapter-09/metrics-server/helmfile.yaml apply
```

13. Grafanaを作成します。

```bash
helmfile -f chapter-09/grafana/grafana/helmfile.yaml apply
```

14. Kialiを作成します。

```bash
helmfile -f chapter-09/kiali/helmfile.yaml apply
```

15. Prometheus、Grafana、Kialiのダッシュボードに接続します。ブラウザから、Prometheus (`http://localhost:20001`) 、Grafana (`http://localhost:8000`) 、Kiali (`http://localhost:20001`) に接続してください。

```bash
kubectl port-forward svc/prometheus-server -n prometheus 9090:9090 & \
  kubectl port-forward svc/grafana -n grafana 8000:80 & \
  kubectl port-forward svc/kiali 20001:20001 -n istio-system
```

16. `http://localhost:9080/productpage?u=normal` から、Bookinfoアプリケーションに接続します。

```bash
kubectl port-forward svc/istio-ingressgateway -n istio-ingress 8080:8080 9080:9080
```

17. 接続時点では未認証のため、detailsサービスとreviewsサービスはproductpageサービスに `403` を返信します。productpageサービスは詳細情報とレビュー情報を取得できないため、ユーザーはこれらを閲覧できません。

18. Sign inボタンをクリックすると、認可コードフローのOIDCが始まります。認可リクエストなどを経て、Keycloakが認証画面をレスポンスするため、ユーザー名を`izzy`とし、パスワードを`izzy`とします。Keycloakの認証に成功すれば、Keycloakに登録された`izzy`ユーザーを使用してBookinfoにSSOできます。

19. OIDCの成功後、productpageサービスはKeycloakから受信したアクセストークンを後続のマイクロサービスに伝播します。detailsサービスとreviewsサービスはKeycloakとの間でアクセストークンを検証し、これが成功すればproductpageサービスに `200` を返信します。productpageサービスは詳細情報とレビュー情報を取得できるようになり、ユーザーはこれらを閲覧できます。

## 機能を実践する

## 掃除

1. Minikubeを削除します。

```bash
minikube delete --profile istio-demo
```

2. dockerコンテナを削除します。

```bash
docker compose -f databases/docker-compose.yaml down all --volumes --remove-orphans
```

3. 他の章を実践するときは、事前に [Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。
