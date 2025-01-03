# 6章

6章では、Istioの回復性管理を学びます。



5. 各マイクロサービスにIstioカスタムリソースをデプロイします。

```bash
helmfile -f 06/bookinfo-app/details/helmfile.yaml apply

helmfile -f 06/bookinfo-app/productpage/helmfile.yaml apply

helmfile -f 06/bookinfo-app/ratings/helmfile.yaml apply

helmfile -f 06/bookinfo-app/reviews/helmfile.yaml apply
```

