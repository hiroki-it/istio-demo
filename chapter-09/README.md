# 9章

9章では、Istioのデプロイパターンを学びます。

今までの章では、Istioコントロールプレーンとマイクロサービスアプリケーションを同じKubernetesクラスターにデプロイしていました。

これらを異なるクラスターにデプロイし、障害の影響を分離します。

1. 9章に取り組む前に、既存のMinikubeクラスターを削除します。

```bash
minikube delete --profile istio-demo
```

2. Minikubeクラスター間を接続するネットワークを作成します。

```bash
docker network create multi-cluster --subnet=172.18.0.0/16 --gateway=172.18.0.1
```
