# 6章

6章では、Istioによる回復性管理を学びます。

回復性管理は、すでに登場したトラフィック管理系リソース (DestinationRule、Gateway、ServiceEntry、VirtualService) で設定します。

これらのリソースを使用して、Istioがマイクロサービスの回復性を管理する様子を確認します。

## セットアップ

1. Istioのトラフィック管理系リソースを作成します。

```bash
helmfile -f chapter-06/bookinfo-app/database/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/details/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f chapter-06/bookinfo-app/reviews/helmfile.yaml apply
```
