1. Bookinfoアプリをデプロイする

```bash
$ ISTIO_VERSION=1.24.1

$ kubectl apply -f https://raw.githubusercontent.com/istio/istio/refs/tags/${ISTIO_VERSION}/samples/bookinfo/platform/kube/bookinfo.yaml
```

2. アプリが正常に稼働していることを確認する

```bash
kubectl get pod -A
```
