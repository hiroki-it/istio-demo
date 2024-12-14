1. Bookinfoアプリをデプロイする

```bash
$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/1.24.1/samples/bookinfo/platform/kube/bookinfo.yaml
```

2. アプリが正常に稼働していることを確認する

```bash
kubectl get pod -A
```
