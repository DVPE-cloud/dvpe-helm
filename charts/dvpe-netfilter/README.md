# dvpe-netfilter

![Version: 0.1](https://img.shields.io/badge/Version-0.1-informational?style=flat-square)

Helm chart for set netfilter rules on Kubelet node

## Installation
Installs dvpe-helm netfilter injector on an existing Kubernetes cluster.

**Note**: The netfilter injector needs to run as root with NET_ADMIN capabilties and use hostNetwork in namespace kube-system.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-cluster-issuer chart

Using values from a file:

```bash
helm install -f values.ymal `HELM_RELEASE_NAME` dvpe/dvpe-netfilter
```

## Configuration

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| netfilter.blocked.interfaces | list | `["eni+"]` | Which kubelet host interfaces should be used to apply the rules    |
| netfilter.blocked.ipv4 | list | `["169.254.169.254/32"]` | Which IPv4 addresses should be blocked from access by the netfilter.blocked.interfaces |
| netfilter.enabled | bool | `true` | Enable or disable the netfilter rule injections |
