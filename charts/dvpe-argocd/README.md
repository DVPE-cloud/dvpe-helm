# dvpe-argocd

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square)

Helm chart for installing Argocd with Project definitions and gloo enabled VirtualService.

## Installation
Installs Argo CD as [gloo](https://www.solo.io/products/gloo/) enabled VirtualService.
Note that this chart assumes that [gloo Api Gateway](https://docs.solo.io/gloo/latest/installation/preparation/) has already been installed and configured on your K8S cluster.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-argocd chart

### Preconditions

Before installing this chart you need to make sure that

* [gloo API Gateway](https://docs.solo.io/gloo/latest/installation/preparation/) has already been installed on the K8S cluster.
* a K8S secret exists on the cluster containing the `certificate` and corresponding `secret key` of the TLS certificate you want to use
  for your service deployment.This secret will then be referenced in your VirtualService section of this chart.  
  You can create this secret via external secrets or simpler with the following `kubectl` command:

  ```bash
  kubectl create secret tls sample_secret \
    --key <PATH_TO_CERT_SECRET_KEY> \
    --cert <PATH_TO_CERT> \
    -n sample_namespace
  ```
  
  The relevant section in your helm config file would then be:
  
  ```yaml
  gloo:
    virtualservice:
      name: sample_service
      spec:
        sslConfig:
          secretRef:
            name: sample_secret
            namespace: sample_namespace
  ```

### Using config from a file:

```bash
helm install -f config.yaml --namespace `TARGET_K8S_NAMESPACE` `HELM_RELEASE_NAME` dvpe/dvpe-argocd
```
**Note**: The structure of `config.yaml` needs to adhere to the chart's value fields (see config section below). `config.yaml` can be defined as a default helm
values file.

#### Notes on gloo VirtualService definitions

The `VirtualService` kind in gloo allows to define a set of routing rules to services deployed on K8S. A `VirtualService` always comes with an `Upstream`
automatically deployed in a pre-defined namespace on the cluster. An `Upstream` in turn specifies the destination to the service inside the cluster.
See [gloo concepts](https://docs.solo.io/gloo/latest/introduction/) for further details.

## Chart Configuration Parameters

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| argo-cd.configs.knownHosts.data.ssh_known_hosts | string | `"github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==\ngitlab.com ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBFSMqzJeV9rUzU4kWitGjeR4PWSa29SPqJ1fVkhtj3Hw9xjLVXVYrU9QlYWrOLXBpQ6KWjbjTDTdDkoohFzgbEY=\ngitlab.com ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf\ngitlab.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9\nssh.dev.azure.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7Hr1oTWqNqOlzGJOfGJ4NakVyIzf1rXYd4d7wo6jBlkLvCA4odBlL0mDUyZ0/QUfTTqeu+tm22gOsv+VrVTMk6vwRU75gY/y9ut5Mb3bR5BV58dKXyq9A9UeB5Cakehn5Zgm6x1mKoVyf+FFn26iYqXJRgzIZZcZ5V6hrE0Qg39kZm4az48o0AUbf6Sp4SLdvnuMa2sVNwHBboS7EJkm57XQPVU3/QpyNLHbWDdzwtrlS+ez30S3AdYhLKEOxAG8weOnyrtLJAUen9mTkol8oII1edf7mWWbWVf0nBmly21+nZcmCTISQBtdcyPaEno7fFQMDD26/s0lfKob4Kw8H\nvs-ssh.visualstudio.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7Hr1oTWqNqOlzGJOfGJ4NakVyIzf1rXYd4d7wo6jBlkLvCA4odBlL0mDUyZ0/QUfTTqeu+tm22gOsv+VrVTMk6vwRU75gY/y9ut5Mb3bR5BV58dKXyq9A9UeB5Cakehn5Zgm6x1mKoVyf+FFn26iYqXJRgzIZZcZ5V6hrE0Qg39kZm4az48o0AUbf6Sp4SLdvnuMa2sVNwHBboS7EJkm57XQPVU3/QpyNLHbWDdzwtrlS+ez30S3AdYhLKEOxAG8weOnyrtLJAUen9mTkol8oII1edf7mWWbWVf0nBmly21+nZcmCTISQBtdcyPaEno7fFQMDD26/s0lfKob4Kw8H\nbitbucket.org ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAubiN81eDcafrgMeLzaFPsw2kNvEcqTKl/VqLat/MaB33pZy0y3rJZtnqwR2qOOvbwKZYKiEO1O6VqNEBxKvJJelCq0dTXWT5pbO2gDXC6h6QDXCaHo6pOHGPUy+YBaGQRGuSusMEASYiWunYN0vCAI8QaXnWMXNMdFP3jHAJH0eDsoiGnLPBlBp4TNm6rYI74nMzgz3B9IikW4WVK+dc8KZJZWYjAuORU3jc1c/NPskD2ASinf8v3xnfXeukU0sJ5N6m5E8VLjObPEO+mN2t/FZTMZLiFqPWc/ALSqnMnnhwrNi2rbfg/rd/IpL8Le3pSBne8+seeFVBoGqzHM9yXw==\n[git.bmwgroup.net]:7999,[160.48.66.47]:7999 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC1mMeortEsruBLnRKltGfQUjA4lghYZWMljdeTdE5Tx86Mrj7WGZVjkNzJYDnoirU8Nb79TbHuYu84mLglqRB/z/2L1K32eCUKR+LipLvqFZvhtTSxlO80UIBBRxyjBwMEpdmfJUqZJCcYw5X+jVADYYfX93/gD92MNzWp6D8tW4fvnWlAaMIKhUxA/k4iXvwA77VpmvIB7Twxt8NHsa4ehER+JzSuZoOIqUARzkhvBuHTRlxTlMuyVGfyOYfixntZ1+BiQsh9r/HxUvAnvwXj5Jb67hPkATKPAibo2tyNCVfoJernlVCrWNEyW1StNboPjxJLeKEzFWbHR6fOa+FB\n"` | List of known hosts of git repositories. See https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#ssh-known-host-public-keys |
| argo-cd.controller.enableStatefulSet | bool | `true` | Deploy the application as a StatefulSet instead of a Deployment, this is required for HA capability. This is a feature flag that will become the default in chart version 3.x |
| argo-cd.controller.logFormat | string | `"json"` |  |
| argo-cd.server.clusterAdminAccess.enabled | bool | `false` | Enables an `admin` user outside of OIDC. The initial password is autogenerated to be the pod name of the Argo CD API server. |
| argo-cd.server.config."oidc.config" | string | `nil` |  |
| argo-cd.server.config.repositories | string | `nil` | List of config repos, as described in https://argoproj.github.io/argo-cd/operator-manual/declarative-setup/#repositories |
| argo-cd.server.configAnnotations | object | `{"helm-chart":"dvpe-helm/dvpe-argocd"}` | Annotations to be added to ArgoCD ConfigMap |
| argo-cd.server.extraArgs | list | `["--insecure"]` | Argo server log format: text|json |
| argo-cd.server.logFormat | string | `"json"` |  |
| argo-cd.server.logLevel | string | `"info"` | Argo server log level |
| argo-cd.server.rbacConfig."policy.csv" | string | `nil` |  |
| argo-cd.server.rbacConfig."policy.default" | string | `"role:readonly"` |  |
| argo-cd.server.rbacConfigAnnotations | object | `{"helm-chart":"dvpe-helm/dvpe-argocd"}` | Annotations to be added to ArgoCD rbac ConfigMap |
| argo-cd.server.service.servicePortHttp | int | `80` | Argo server service http port |
| argo-cd.server.service.servicePortHttpName | string | `"http"` | Argo server service http port name, can be used to route traffic via istio |
| gloo.enabled | bool | `true` | When set to false only the application's deployment resources will be installed with this chart. Can be used to explicitly avoid deploying a VirtualService resource. |
| gloo.namespace | string | `"gloo-system"` | `Namespace` where all Gloo resources are deployed. |
| gloo.upstream.namespace | string | `nil` | `Namespace` where gloo upstream is deployed. |
| gloo.virtualservice.namespace | string | `"gloo-system"` | `Namespace` where gloo virtualservice is deployed. |
| gloo.virtualservice.spec.sslConfig.secretRef.name | string | `nil` | Name of the secret containing the certificate information for this deployment. |
| gloo.virtualservice.spec.sslConfig.secretRef.namespace | string | `"gloo-system"` | Namespace where the secret is located. If empty, gloo namespace is used. |
| gloo.virtualservice.spec.virtualHost.domains | string | `nil` | `DNS domain name` this service will be published to. |
| gloo.virtualservice.spec.virtualHost.routes.additionalRoutes | string | `nil` | List of route configurations for this `VirtualService`. See [gloo VirtualService Specification](https://docs.solo.io/gloo-edge/latest/introduction/architecture/concepts/#virtual-services) for details |
| gloo.virtualservice.spec.virtualHost.routes.appPath | string | `nil` | Path to `appUrl` where the service can be accessed. Pre-defined route in `VirtualService`. |
| gloo.virtualservice.spec.virtualHost.routes.callbackUrlPath | string | `nil` | Path to `callbackUrl` which needs to be registered at the Identity Provider. Pre-defined route in `VirtualService`. |
