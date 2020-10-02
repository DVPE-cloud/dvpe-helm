# dvpe-deployment-gloo

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square)

Helm chart for installing microservices as gloo enabled VirtualService definitions.

## Installation
Installs a Microservice Project as [gloo](https://www.solo.io/products/gloo/) enabled VirtualService.
Note that this chart assumes that [gloo Api Gateway](https://docs.solo.io/gloo/latest/installation/preparation/) has already been installed and configured on your K8S cluster.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-deployment-gloo chart

### Preconditions

Before installing this chart you need to make sure that

* [gloo API Gateway](https://docs.solo.io/gloo/latest/installation/preparation/) has already been installed on the K8S cluster.
* a namespace where the service shall be installed into has already been created on the K8S cluster.
* a K8S secret exists on the cluster containing the `certificate` and corresponding `secret key` of the TLS certificate you want to use.
for your service deployment. This secret will then be referenced in your VirtualService section of this chart.
You can create this secret with the following `kubectl` command:
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

* a K8S secret with name `docker-reg-secret` exists in the same namespace as the one in which your service is going to be deployed. This secret needs to contain
the credential information for accessing the docker registry you are using for deployment.
You can create this secret with the following `kubectl` command:
  ```bash
  kubectl create secret --namespace <SERVICE_NAMESPACE> docker-registry docker-reg-secret \
    --docker-server=<URL_TO_DOCKER_REGISTRY> \
    --docker-username=<DOCKER_USERNAME> \
    --docker-password=<DOCKER_PASSWORD> \
    --docker-email=<DOCKER_EMAIL>
  ```

### Using config from a file:

```bash
helm install -f config.yaml --namespace `TARGET_K8S_NAMESPACE` `HELM_RELEASE_NAME` dvpe/dvpe-deployment-gloo
```
**Note**: The structure of `config.yaml` needs to adhere to the chart's value fields (see config section below). `config.yaml` can be defined as a default helm
values file.

#### Notes on gloo VirtualService definitions

The `VirtualService` kind in gloo allows to define a set of routing rules to services deployed on K8S. A `VirtualService` always comes with an `Upstream`
automatically deployed in a pre-defined namespace on the cluster. An `Upstream` in turn specifies the destination to the service inside the cluster.
See [gloo concepts](https://docs.solo.io/gloo/1.1.0/introduction/concepts/) for further details.

`Upstreams` have a special syntax you need to use when you define a `VirtualService` for deployment:

Upstream Name = <K8S_NAMESPACE_NAME>-<K8S_SERVICE_NAME>-<K8S_SERVICE_PORT>

Assume you have a K8S service specified in the following way:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: sample-svc
  namespace: sample
spec:
  type: ClusterIP
  ports:
    - name: http
      protocol: TCP
      port: 80
      targetPort: 80
    - name: https
      protocol: TCP
      port: 443
      targetPort: 80
  selector:
    app: sample
```

Then the `Upstreams` created by gloo will be:

* `sample-sample-svc-80`
* `sample-sample-svc-443`

The corresponding gloo `VirtualService` spec could then look like the following:

```yaml
gloo:
  virtualservice:
    name: sample-vs
    spec:
      sslConfig:
        secretRef:
          name: gloo-tls
          namespace: gloo-system
      virtualHost:
        domains:
          - 'sample.my.domain.name'
        routes:
          - matchers:
              - prefix: /
            routeAction:
              single:
                upstream:
                  name: sample-sample-svc-80
                  namespace: gloo-system
```

## Chart Configuration Parameters

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalparameters.configMapApplied | bool | `false` | Set to `true` if you want to add a custom `ConfigMap` for your deployment. |
| additionalparameters.secretsApplied | bool | `false` | Set to `true` if you want to add a custom `Secret` for your deployment. |
| additionalparameters.yamlConfigFileApplied | bool | `false` | Set to `true` if you want to add a custom yaml configuration for your deployment. |
| deployment.spec.containers.readinessProbe.failureThreshold | int | `3` | Number of times to retry the probe before giving up. |
| deployment.spec.containers.readinessProbe.httpGet.path | string | `"/"` | Service's http path on which to execute a readinessProbe |
| deployment.spec.containers.readinessProbe.httpGet.port | int | `80` | Service's http port on which to execute a readinessProbe |
| deployment.spec.containers.readinessProbe.httpGet.scheme | string | `"HTTP"` | Http Scheme to use for readinesProbe. Can be either `HTTP` or `HTTPS`. |
| deployment.spec.containers.readinessProbe.initialDelaySeconds | int | `5` | Amount of time to wait before performing the first probe. |
| deployment.spec.containers.readinessProbe.periodSeconds | int | `10` | How often to perform the probe (in seconds). |
| deployment.spec.containers.readinessProbe.successThreshold | int | `1` | Threshold to be considered successful after having failed. |
| deployment.spec.containers.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out. |
| deployment.spec.image.pullPolicy | string | `"Always"` | The default rule for downloading images. |
| deployment.spec.image.repository | string | `nil` | The docker repository to pull the service image from. |
| deployment.spec.image.tag | string | `"latest"` | The image version to use. |
| deployment.spec.replicas | int | `2` | The number of service instances to deploy. |
| deployment.spec.resources.limits.cpu | string | `"200m"` | Total amount of CPU time that a container can use every 100 ms. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.limits.memory | string | `"235M"` | The memory limit for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.requests.cpu | string | `"150m"` | Fractional amount of CPU allowed for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.requests.memory | string | `"200M"` | Amount of memory reserved for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.serviceAccountName | string | `"default"` | The ServiceAccount this service will be associated with. |
| gloo.virtualservice.name | string | `nil` | Name of the `VirtualService` to deploy |
| gloo.virtualservice.spec.sslConfig.secretRef.name | string | `nil` | Name of the secret containing the certificate information for this deployment. |
| gloo.virtualservice.spec.sslConfig.secretRef.namespace | string | `nil` | Name of the namespace where the secret is located. |
| gloo.virtualservice.spec.virtualHost.domains | string | `nil` | List of DNS domain names this service will be published to. |
| gloo.virtualservice.spec.virtualHost.routes | string | `nil` | List of route configurations for this `VirtualService`. See [gloo VirtualService Specification](https://docs.solo.io/gloo/1.1.0/introduction/concepts/#virtual-services) for details |
| service.spec.ports.http.port | int | `80` | The http port the service is exposed to in the cluster. |
| service.spec.ports.http.targetPort | int | `80` | The http port the service listens to and to which requests will be sent. |
| service.spec.ports.https.port | int | `443` | The https port the service is exposed to in the cluster. |
| service.spec.ports.https.targetPort | int | `80` | The http port the service listens to and to which requests will be sent. |
| service.spec.type | string | `"ClusterIP"` | Specify what kind of service to deploy. See [Kubernetes Service Spec](https://kubernetes.io/docs/concepts/services-networking/service/) for details |
