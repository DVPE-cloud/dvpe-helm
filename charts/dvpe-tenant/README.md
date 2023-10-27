# dvpe-tenant

![Version: 0.1.0](https://img.shields.io/badge/Version-0.1.0-informational?style=flat-square)

Helm chart for creating the resources with information readable from the the GitHub API. For the beginning, this includes only the ArgoCD resources.

## Installation
Installs a tenant's ArgoCD resources into a cluster.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-tenant chart

Using config from a file:

```bash
helm install -f values.yaml --namespace `TARGET_K8S_NAMESPACE` `HELM_RELEASE_NAME` dvpe/dvpe-tenant
```

## Configuration

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| repositories | list | `[]` |  |
