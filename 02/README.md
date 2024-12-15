# 2章

2章では、マイクロサービスアーキテクチャにIstioを導入します。

1. Nginx Ingress Controllerを削除します。後ほど、IstioのサービスメッシュゲートウェイのIstio IngressGatewayに置き換えます。

```bash

```

2. Istioのカスタムリソース定義を作成する。

```bash

```

3. Istioコントロールプレーンをデプロイします。

```bash

```

4. Istio IngressGatewayをデプロイします。

```bash

```

5. Istio EgressGatewayをデプロイします。

```bash

```

6. 各マイクロサービスで、Istio (VirtualService、DestinationRule) をデプロイします。

```bash

```
