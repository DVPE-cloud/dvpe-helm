# dvpe-deployment-gloo

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square)

Helm chart for installing microservices as gloo enabled VirtualService definitions.

## Installation
Installs a Microservice Project as gloo enabled VirtualService.

### Add Helm repository

```shell
helm repo add dvpe https://dvpe-cloud.github.io/dvpe-helm
helm repo update
```

## Install dvpe-deployment-gloo chart

### Preconditions

Before installing this chart you need to make sure that

* a K8S secret exists on the cluster containing the `certificate` and corresponding `secret key` of the TLS certificate you want to use
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

###Using config from a file:

```bash
helm install -f config.yaml --namespace `TARGET_K8S_NAMESPACE` `HELM_RELEASE_NAME` dvpe/dvpe-deployment-gloo
```

**Note**: The structure of `config.yaml` needs to adhere to the chart's value fields (see config section below). `config.yaml` can be defined as a default helm
values file.

## Configuration

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| additionalparameters.configMapApplied | bool | `false` |  |
| additionalparameters.secretsApplied | bool | `false` |  |
| additionalparameters.yamlConfigFile.anotherConfigFileProp | int | `1` |  |
| additionalparameters.yamlConfigFile.configFileProp.sub | string | `"value"` |  |
| additionalparameters.yamlConfigFileApplied | bool | `false` |  |
| deployment.spec.connection.http.port | int | `8080` |  |
| deployment.spec.containers.readinessProbe.failureThreshold | int | `3` |  |
| deployment.spec.containers.readinessProbe.httpGet.path | string | `nil` |  |
| deployment.spec.containers.readinessProbe.httpGet.port | string | `nil` |  |
| deployment.spec.containers.readinessProbe.httpGet.scheme | string | `"HTTP"` |  |
| deployment.spec.containers.readinessProbe.initialDelaySeconds | int | `5` |  |
| deployment.spec.containers.readinessProbe.periodSeconds | int | `10` |  |
| deployment.spec.containers.readinessProbe.successThreshold | int | `1` |  |
| deployment.spec.containers.readinessProbe.timeoutSeconds | int | `1` |  |
| deployment.spec.image.pullPolicy | string | `"Always"` |  |
| deployment.spec.image.repository | string | `nil` |  |
| deployment.spec.image.tag | string | `"latest"` |  |
| deployment.spec.replicas | int | `2` |  |
| deployment.spec.resources.limits.cpu | string | `"200m"` |  |
| deployment.spec.resources.limits.memory | string | `"235M"` |  |
| deployment.spec.resources.requests.cpu | string | `"150m"` |  |
| deployment.spec.resources.requests.memory | string | `"200M"` |  |
| deployment.spec.serviceAccountName | string | `"default"` |  |
| gloo.virtualservice.name | string | `nil` |  |
| gloo.virtualservice.spec.sslConfig.secretRef.name | string | `nil` |  |
| gloo.virtualservice.spec.sslConfig.secretRef.namespace | string | `nil` |  |
| gloo.virtualservice.spec.virtualHost.domains | string | `nil` |  |
| gloo.virtualservice.spec.virtualHost.routes[0].matchers[0].prefix | string | `nil` |  |
| gloo.virtualservice.spec.virtualHost.routes[0].routeAction.single.upstream.name | string | `nil` |  |
| gloo.virtualservice.spec.virtualHost.routes[0].routeAction.single.upstream.namespace | string | `nil` |  |
| service.spec.ports.http | int | `8080` |  |
| service.spec.ports.targetPort | int | `8080` |  |
| service.spec.type | string | `"ClusterIP"` |  |
