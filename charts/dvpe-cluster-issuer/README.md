# dvpe-cluster-issuer

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square)

Helm chart for installing jetstack cert manager resources, to be used in Kubernetes automation scripts.

## Installation
Installs [jetstack's cert-manager](https://cert-manager.io) resources `ClusterIssuer` and `Certificate` on an existing Kubernetes cluster.

The ClusterIssuer and Certificate deployed with this chart should mainly be used for issuing Certificates for a wildcard DNS domain name. This can be useful for an initial
setup of cert-manager where a service's domain name can then arbitrarily be chosen based upon the Certificate's wildcard DNS name.
If Certificates should be issued individually for an application then you have to deploy the certificate together with the application and you should not use this chart.

See [Certificate Spec](https://cert-manager.io/docs/usage/certificate/) for details.

### Example

Assume you defined the following DNS configuration:

```
issuer.spec.acme.solvers.selector.dnsZones  = "mydomain.cloud"
cert.spec.dnsNames                          = "*.mydomain.cloud"
```

You will then be able to point your service to an arbitrary URL, i.e. `myservice.mydomain.cloud` without any further configuration. cert-manager will then
issue a new certificate at deployment time.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-cluster-issuer chart

Using config from a file:

```bash
helm install `HELM_RELEASE_NAME` `HELM_CHART_REPO` -f config.yaml
```

**Note**: The structure of `config.yaml` needs adhere to the chart's value fields (see below) and can be used as
simple helm values file.

## Configuration

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cert.metadata.namespace | string | `nil` | The name of the namespace the certificate should be installed to |
| cert.spec.commonName | string | `nil` | The commonName field can also be omitted. If so, the first element in the dnsNames list will be the common name. |
| cert.spec.dnsNames | string | `nil` | List of Subject Alternative Names associated with the certificate |
| issuer.metadata.namespace | string | `nil` | The name of the namespace the ClusterIssuer should be installed to |
| issuer.spec.acme.email | string | `nil` | Email for cert update notifications |
| issuer.spec.acme.server.prod | string | `"https://acme-v02.api.letsencrypt.org/directory"` | URL to ACME prod environment |
| issuer.spec.acme.server.staging | string | `"https://acme-staging-v02.api.letsencrypt.org/directory"` | URL to ACME staging environment |
| issuer.spec.acme.server.useProd | bool | `false` | Set to true if the prod URL of the default ACME server (Letsencrypt) should be used for issuing certificates. If set to false the staging environment will be used. |
| issuer.spec.acme.solvers.dns01.route53.hostedZoneID | string | `nil` | AWS IAM role containing permissions to create record sets in Route53 |
| issuer.spec.acme.solvers.dns01.route53.region | string | `nil` | AWS Region to use |
| issuer.spec.acme.solvers.dns01.route53.role | string | `nil` | AWS Route53 hosted zone id to use for DNS challenges |
| issuer.spec.acme.solvers.selector.dnsZones | string | `nil` | List of DNS zones that can be used by this solver |
