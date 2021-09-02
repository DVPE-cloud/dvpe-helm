# dvpe-certificate-issuer-controller

![Version: 0.0.4](https://img.shields.io/badge/Version-0.0.4-informational?style=flat-square)

Helm chart for deploying a custom certificate issuer controller. The certificate issuer controller is a [cert-manager](https://cert-manager.io/docs/) resource managing certificate requests in a private PKI.

## Installation
Installs dvpe-helm certificate issuer controller on an existing Kubernetes cluster.

**Note**: When Pod Security Policies are used in your cluster, then they need to reflect those requirements.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-cluster-issuer chart

Using values from a file:

```bash
helm install -f values.ymal `HELM_RELEASE_NAME` dvpe/dvpe-certificate-issuer-controller
```

## Configuration

The following table lists the configurable parameters of the chart and its default values.
s
## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| issuercontroller.externalsecrets.name | string | `nil` | The name of the external secret key containing the docker credentials for this deployment |
| issuercontroller.name | string | `nil` | Name of issuer-controller deployment |
| issuercontroller.namespace | string | `nil` | Namespace for issuer-controller deployment |
| issuercontroller.plane.name | string | `"issuer-controller"` | Name of the Controller Plane |
| issuercontroller.spec.image | object | `{"name":null,"pullPolicy":"Always","repository":null,"tag":null}` | Name of issuer-controller deployment image |
| issuercontroller.spec.image.name | string | `nil` | The image name to use. |
| issuercontroller.spec.image.pullPolicy | string | `"Always"` | The default rule for downloading images. |
| issuercontroller.spec.image.repository | string | `nil` | The docker repository to pull the service image from. |
| issuercontroller.spec.image.tag | string | `nil` | The image version to use. |
