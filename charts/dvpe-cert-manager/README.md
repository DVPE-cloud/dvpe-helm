# dvpe-cert-manager

Helm chart for installing jetstack cert manager resources, to be used in Kubernetes automation scripts.

Current chart version is `0.0.2`

**Homepage:** <https://github.com/dvpe-cloud/dvpe-helm>

## Installation
Installs [jetstack's cert-manager](https://cert-manager.io) resources (`ClusterIssuer` and `Certificate) on an existing Kubernetes cluster.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-cert-manager chart

Using config from a file:

```bash
helm install `HELM_RELEASE_NAME` `HELM_CHART_REPO` -f config.yaml
```

**Note**: The structure of `config.yaml` needs to look like the following:

```yaml
issuer:
  metadata:
    namespace:
  spec:
    acme:
      email:
      solvers:
        dns01:
          route53:
            region:
            hostedZoneID:
            role:
        selector:
          dnsZones:
cert:
  metadata:
    namespace:
  spec:
    commonName:
    dnsNames:
```

## Configuration

The following table lists the configurable parameters of the chart and the default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cert.metadata.namespace | string | `nil` |  |
| cert.spec.commonName | string | `nil` |  |
| cert.spec.dnsNames | string | `nil` |  |
| issuer.metadata.namespace | string | `nil` |  |
| issuer.spec.acme.email | string | `nil` |  |
| issuer.spec.acme.server.prod | string | `"https://acme-v02.api.letsencrypt.org/directory"` |  |
| issuer.spec.acme.server.staging | string | `"https://acme-staging-v02.api.letsencrypt.org/directory"` |  |
| issuer.spec.acme.server.useProd | bool | `false` |  |
| issuer.spec.acme.solvers.dns01.route53.hostedZoneID | string | `nil` |  |
| issuer.spec.acme.solvers.dns01.route53.region | string | `nil` |  |
| issuer.spec.acme.solvers.dns01.route53.role | string | `nil` |  |
| issuer.spec.acme.solvers.selector.dnsZones | string | `nil` |  |