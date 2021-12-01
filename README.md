# coredns-multicluster-build

Steps to build [coredns](https://github.com/coredns/coredns) with [multicluster plugin](https://github.com/coredns/multicluster).

Build binaries:

```shell
make build
```

Build docker images for each architecture, with version `v1.8.6` and default `latest` tags:

```shell
make VERSION=v1.8.6 DOCKER=runakash docker-build
```

Push docker images

```shell
make VERSION=v1.8.6 DOCKER=runakash docker-push
```
