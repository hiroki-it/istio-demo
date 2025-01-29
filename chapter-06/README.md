# 6章

6章では、Istioによる回復性管理を学びます。

Istioカスタムリソース (DestinationRule、Gateway、ServiceEntry、VirtualService) を使用して、Istioがマイクロサービスの回復性を管理する様子を確認します。


## セットアップ

1. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f chapter-06/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/reviews/helmfile.yaml apply
```
