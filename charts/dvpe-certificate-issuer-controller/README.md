# dvpe-certificate-issuer-controller

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square)

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
| issuercontroller | object | `{"externalsecrets":{"clusterIssuer":null,"dockerCredentials":null,"name":null},"plane":{"name":"wadtfy-cert-issuer-controller-system"},"spec":{"image":{"name":"wadtfy-issuer","pullPolicy":"IfNotPresent","repository":null,"tag":"v1.2.0"}}}` | -----------------------------# |
| issuercontroller.externalsecrets.clusterIssuer | string | `nil` | The name of the external secret for the cluster certificate issuer |
| issuercontroller.externalsecrets.dockerCredentials | string | `nil` | The name of the external secret key containing the docker credentials for this deployment (earlier: `issuercontroller.externalsecrets.name`) |
| issuercontroller.externalsecrets.name | string | `nil` | DEPRECATED; rename to `issuercontroller.externalsecrets.dockerCredentials` |
| issuercontroller.plane.name | string | `"wadtfy-cert-issuer-controller-system"` | Name of the Controller Plane |
| issuercontroller.spec.image | object | `{"name":"wadtfy-issuer","pullPolicy":"IfNotPresent","repository":null,"tag":"v1.2.0"}` | Name of issuer-controller deployment image |
| issuercontroller.spec.image.name | string | `"wadtfy-issuer"` | The image name to use. |
| issuercontroller.spec.image.pullPolicy | string | `"IfNotPresent"` | The default rule for downloading images. |
| issuercontroller.spec.image.repository | string | `nil` | The docker repository to pull the service image from. |
| issuercontroller.spec.image.tag | string | `"v1.2.0"` | The image version to use. |
