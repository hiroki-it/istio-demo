1. Kialiをデプロイします。

```bash
helmfile -f 02/kiali/helmfile.yaml apply
```

2. メッシュトポロジーを可視化します。

```bash
kubectl port-forward svc/kiali 20001:20001 -n istio-system
```
