# dvpe-cluster-issuer

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square)

Helm chart for installing cert-manager's ClusterIssuer resource, to be used in Kubernetes automation scripts.

## Installation
Installs [jetstack cert-manager's](https://cert-manager.io) `ClusterIssuer` resource on an existing Kubernetes cluster.

The `ClusterIssuer` deployed with this chart should mainly be used for issuing Certificates for a wildcard DNS domain name in combination with an ACME enabled service like i.e. [Letsencrypt](https://letsencrypt.org/de/). This can be useful for an initial
setup of cert-manager during an IaC setup where a service's domain name can then arbitrarily be chosen based upon the Certificate's wildcard DNS name.

**Note**: In order to allow DNS Challenges the `ClusterIssuer` needs to have permissions to create temporary DNS record sets on your cloud provider. This current setup is based upon AWS Route53 and won't work
for other cloud providers.

`Certificate` resources need to be provisioned separately together with the service that should later issue certificates. This can i.e. be an API Gateway Service or Ingress Controller.
You can use the [dvpe certificate chart](https://github.com/DVPE-cloud/dvpe-helm/tree/master/charts/dvpe-cluster-issuer) for installing those kind of resources.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-cluster-issuer chart

Using config from a file:

```bash
helm install -f config.yaml --namespace `TARGET_K8S_NAMESPACE` `HELM_RELEASE_NAME` dvpe/dvpe-cluster-issuer
```

**Note**: The structure of `config.yaml` needs to adhere to the chart's value fields (see config section below). `config.yaml` can be defined as a default helm
values file.

## Configuration

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| clcm.healthCheckTimeoutInSeconds | int | `60` | CLCM health check interval in seconds |
| clcm.host | string | `nil` | CLCM host |
| clcm.port | string | `nil` | CLCM port |
| clcm.secretsNamespace | string | `"cert-manager-system"` | Namespace, where secrets are deployed |
| issuers | object | `{"internet":{"caInstance":null,"certificateDateCAType":null,"ciClient":null,"ciContactEmail":null,"ciID":null,"ciRequester":null,"ciType":null,"secretsManagerSecretName":null}}` | map of objects: each entry describes a new cluster issuer |
| issuers.internet.caInstance | string | `nil` | CA instance |
| issuers.internet.certificateDateCAType | string | `nil` | CA type |
| issuers.internet.ciClient | string | `nil` | CI client |
| issuers.internet.ciContactEmail | string | `nil` | CI contact e-mail |
| issuers.internet.ciID | string | `nil` | CI id |
| issuers.internet.ciRequester | string | `nil` | CI requester |
| issuers.internet.ciType | string | `nil` | CI type |
| issuers.internet.secretsManagerSecretName | string | `nil` | Secret in AWS SecretsManager containing CLCM connect credentials |
