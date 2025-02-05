# 6章

6章では、Istioによる回復性管理を学びます。

回復性管理は、すでに登場したトラフィック管理系リソース (DestinationRule、Gateway、ServiceEntry、VirtualService) で設定します。

## セットアップ

1. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-06/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/reviews/helmfile.yaml apply
```

## 機能を実践する

## 掃除

Minikubeを削除します。

他の章を実践するときは、[Kubernetesクラスターのセットアップ手順](../README.md) を改めて実施してください。

```bash
minikube delete --profile istio-demo
```
