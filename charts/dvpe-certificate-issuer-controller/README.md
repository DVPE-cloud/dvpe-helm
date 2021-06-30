# dvpe-certificate-issuer-controller

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square)

Helm chart for deploy certificate issuer controller

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
| issuercontroller.externalsecrets.name | string | `nil` | The name of external secret key (dataFroms) |
| issuercontroller.namespace | string | `nil` | Namespace for issuer-controller deployment |
| issuercontroller.plane.name | string | `"issuer-controller"` | Name of the Controller Plane |
| issuercontroller.spec.image | object | `{"name":null,"pullPolicy":"Always","repository":null,"tag":null}` | Name of issuer-controller deployment image |
| issuercontroller.spec.image.name | string | `nil` | The image name to use. |
| issuercontroller.spec.image.pullPolicy | string | `"Always"` | The default rule for downloading images. |
| issuercontroller.spec.image.repository | string | `nil` | The docker repository to pull the service image from. |
| issuercontroller.spec.image.tag | string | `nil` | The image version to use. |
