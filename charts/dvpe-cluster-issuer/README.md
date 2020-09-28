# dvpe-cluster-issuer

![Version: 0.0.2](https://img.shields.io/badge/Version-0.0.2-informational?style=flat-square)

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
| issuer.metadata.name | string | `"default"` | The name of the ClusterIssuer |
| issuer.metadata.namespace | string | `nil` | The name of the namespace the ClusterIssuer should be installed to |
| issuer.spec.acme.email | string | `nil` | Email for cert update notifications |
| issuer.spec.acme.server.prod | string | `"https://acme-v02.api.letsencrypt.org/directory"` | URL to ACME prod environment |
| issuer.spec.acme.server.staging | string | `"https://acme-staging-v02.api.letsencrypt.org/directory"` | URL to ACME staging environment |
| issuer.spec.acme.server.useProd | bool | `false` | Set to true if the prod URL of the default ACME server (Letsencrypt) should be used for issuing certificates. If set to false the staging environment will be used. |
| issuer.spec.acme.solvers.dns01.route53.hostedZoneID | string | `nil` | AWS IAM role containing permissions to create record sets in Route53 |
| issuer.spec.acme.solvers.dns01.route53.region | string | `nil` | AWS Region to use |
| issuer.spec.acme.solvers.dns01.route53.role | string | `nil` | AWS Route53 hosted zone id to use for DNS challenges |
| issuer.spec.acme.solvers.selector.dnsZones | string | `nil` | List of DNS zones that can be used by this solver |
