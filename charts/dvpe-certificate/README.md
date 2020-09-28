# dvpe-certificate

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square)

Helm chart for installing cert-manager's Certificate resource, to be used in Kubernetes automation scripts.

## Installation
Installs [jetstack cert-manager's](https://cert-manager.io) `Certificate` resource on an existing Kubernetes cluster.

Supposed you have the relevant `RBAC` permissions on your Kubernetes cluster, this chart's `Certificate` can be deployed into an arbitrary namespace.
Before deploying this resource make sure that a cert-manager `Issuer` resource (`ClusterIssuer` or `Issuer` kind) has already been deployed on your cluster.

See [Certificate Spec](https://cert-manager.io/docs/usage/certificate/) for details.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-certificate chart

Using config from a file:

```bash
helm install -f config.yaml --namespace `TARGET_K8S_NAMESPACE` `HELM_RELEASE_NAME` dvpe/dvpe-certificate
```

**Note**: The structure of `config.yaml` needs to adhere to the chart's value fields (see config section below). `config.yaml` can be defined as a default helm
values file.

## Configuration

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| cert.metadata.name | string | `nil` | The name of the certificate to create |
| cert.metadata.namespace | string | `nil` | The name of the namespace the certificate should be installed to |
| cert.spec.commonName | string | `nil` | The commonName field can also be omitted. If so, the first element in the dnsNames list will be the common name. |
| cert.spec.dnsNames | string | `nil` | List of Subject Alternative Names associated with the certificate |
| cert.spec.issuerRef.name | string | `nil` | Name of the CLusterIssuer this Certificate should be issued by. |
| cert.spec.secretName | string | `nil` | The name of the secret that will store the certificate's credentials. |
