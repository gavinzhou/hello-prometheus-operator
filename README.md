# hello-prometheus-opeartor

## Quickstart

## Install Dep

```sh
go get github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb
```

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
