# hello-prometheus-opeartor

## Quickstart

### change your remote url with `orangesys.jsonnet` file

example

```sh
url: 'http://demo.t.orangesys.io/api/v1/receive',
```

### create manifest file

```sh
make build
```

### Install prometheus to your k8s cluster

```sh
kubectl apply -f manifest
```
