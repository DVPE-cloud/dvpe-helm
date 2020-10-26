# dvpe-deployment-gloo

![Version: 1.0.0](https://img.shields.io/badge/Version-1.0.0-informational?style=flat-square)

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
  If you like to use a different name, please adjust the name of the secret in your `values.yaml`

* a K8S secret with name `webeam-oidc` exists in the same namespace in which your service is going to be deployed.
This secret needs to contain the client_secret information as base64 encoded string.
Gloo expects a trailing newline at the secret string.
You can encode your secret with the following command:
    ```bash
    echo 'clientSecret: <clientSecretFromIDP>' | base64
    ```
    Replace `<yourClientSecret>` below with the output of the previous command.
    You can create this secret with the following `kubectl` command:
    ```bash
    <<EOF | kubectl apply -f -
    apiVersion: v1
    kind: Secret
    type: Opaque
    metadata:
      annotations:
        resource_kind: '*v1.Secret'
      name: webeam-oidc-totally-new
      namespace: argo-apps
    data:
      oauth: <yourClientSecret>
    EOF
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
| autoscaling.maxReplicas | int | `5` | Defines `maxReplicas` of Pods scaled automatically by Horizontal Pod Autoscaler (HPA). |
| autoscaling.metrics.resource.cpu.targetAverageUtilization | int | `80` | Defines cpu utilization threshold in % for the HPA to scale up new pods. |
| autoscaling.minReplicas | int | `1` | Defines `minReplicas` of Pods scaled automatically by Horizontal Pod Autoscaler (HPA). |
| datadog.enabled | bool | `true` | When set to true Datadog is enabled and all logs, metrics and traces will be sent to Datadog. |
| datadog.source | string | `nil` | Defines the source which creates log outputs. Source defines the log format and triggers Datadog parser pipelines |
| datadog.team | string | `nil` | Label in Datadog for the responsible team |
| deployment.podAnnotations | object | `{}` | Object of additional `podAnnotations`. |
| deployment.spec.containers.readinessProbe.failureThreshold | int | `3` | Number of times to retry the probe before giving up. |
| deployment.spec.containers.readinessProbe.httpGet.path | string | `"/"` | Service's http path on which to execute a readinessProbe |
| deployment.spec.containers.readinessProbe.httpGet.port | int | `80` | Service's http port on which to execute a readinessProbe |
| deployment.spec.containers.readinessProbe.httpGet.scheme | string | `"HTTP"` | Http Scheme to use for readinesProbe. Can be either `HTTP` or `HTTPS`. |
| deployment.spec.containers.readinessProbe.initialDelaySeconds | int | `5` | Amount of time to wait before performing the first probe. |
| deployment.spec.containers.readinessProbe.periodSeconds | int | `10` | How often to perform the probe (in seconds). |
| deployment.spec.containers.readinessProbe.successThreshold | int | `1` | Threshold to be considered successful after having failed. |
| deployment.spec.containers.readinessProbe.timeoutSeconds | int | `1` | Number of seconds after which the probe times out. |
| deployment.spec.image.name | string | `nil` | The image name to use. |
| deployment.spec.image.pullPolicy | string | `"Always"` | The default rule for downloading images. |
| deployment.spec.image.repository | string | `nil` | The docker repository to pull the service image from. |
| deployment.spec.image.tag | string | `"latest"` | The image version to use. |
| deployment.spec.imagePullSecrets | string | `"docker-reg-secret"` | Image Pull Secret to access docker registry. |
| deployment.spec.replicas | int | `1` | The number of service instances to deploy. |
| deployment.spec.resources.limits.cpu | string | `"200m"` | Total amount of CPU time that a container can use every 100 ms. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.limits.memory | string | `"235M"` | The memory limit for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.requests.cpu | string | `"150m"` | Fractional amount of CPU allowed for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.requests.memory | string | `"200M"` | Amount of memory reserved for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.serviceAccountName | string | `"default"` | The ServiceAccount this service will be associated with. |
| externalSecrets.service.key | string | `nil` | `Key` to AWS Secret Manager object where all sensitive application data should be stored. Each key in the Secret Manager Object should be named like your needed environment variable |
| gloo.authConfig.name | string | `"auth-plugin"` | Prefix of the `Auth Config Plugin`. Final name will be <prefix>-<service-name> |
| gloo.authConfig.namespace | string | `nil` | Namespace where the `Auth Config Plugin` is located. If empty, release namespace is used. |
| gloo.authConfig.spec.configs.additionalPlugins | string | `nil` | List of plugins which should be added to the plugin chain. Expected format is a valid yaml with the `pluginAuth`. See [gloo Plugin Auth](https://docs.solo.io/gloo/latest/guides/security/auth/extauth/plugin_auth/#create-an-authconfig-resource) for details |
| gloo.authConfig.spec.configs.cachePlugin.config.AwsRegion | string | `"eu-west-1"` | `AwsRegion` where the cache is located |
| gloo.authConfig.spec.configs.cachePlugin.config.CacheTableName | string | `"auth-cache-dev"` | `CacheTableName` of the auth cache |
| gloo.authConfig.spec.configs.cachePlugin.name | string | `"AuthFlow"` | `Name` of the cache plugin |
| gloo.authConfig.spec.configs.oauth.app_url | string | `nil` | `BaseUrl` of the app |
| gloo.authConfig.spec.configs.oauth.client_id | string | `nil` | Registered `ClientID` at the IDP |
| gloo.authConfig.spec.configs.oauth.client_secret_ref.name | string | `"webeam-oidc"` | Name of the `Secret`. Gloo expects a k8s secret with the key `oauth` and base64 encoded value `clientSecret: secretValue` |
| gloo.authConfig.spec.configs.oauth.client_secret_ref.namespace | string | `nil` | Namespace were the `Secret` is located. If empty, release namespace is used. |
| gloo.authConfig.spec.configs.oauth.issuer_url | string | `nil` | Issuer URL to the Identity Provider. Gloo adds `.well-known/openid-configuration` to the url automatically |
| gloo.authConfig.spec.configs.oauth.scopes | string | `nil` | List of OIDC scopes. `openid` is set per default by Gloo and must not be added here |
| gloo.enabled | bool | `true` | When set to true only the application's deployment resources will be installed with this chart. Can be used to explicitly avoid deploying a VirtualService resource. |
| gloo.namespace | string | `"gloo-system"` | `Namespace` where all Gloo resources are deployed. |
| gloo.upstream.namespace | string | `"gloo-system"` | `Namespace` where gloo upstream is deployed. |
| gloo.virtualservice.spec.sslConfig.secretRef.name | string | `"gloo-public-tls"` | Name of the secret containing the certificate information for this deployment. |
| gloo.virtualservice.spec.sslConfig.secretRef.namespace | string | `nil` | Namespace where the secret is located. If empty, gloo namespace is used. |
| gloo.virtualservice.spec.virtualHost.domains | string | `nil` | List of DNS domain names this service will be published to. TODO: Check if more than one domain is necessary. Dependencies to app_url in auth config and sslconfig.secretRef |
| gloo.virtualservice.spec.virtualHost.routes.additionalRoutes | string | `nil` | List of route configurations for this `VirtualService`. See [gloo VirtualService Specification](https://docs.solo.io/gloo/1.1.0/introduction/concepts/#virtual-services) for details |
| gloo.virtualservice.spec.virtualHost.routes.appPath | string | `"/"` | Path to `appUrl` where the service can be accessed. Pre-defined route in `VirtualService`. |
| gloo.virtualservice.spec.virtualHost.routes.callbackUrlPath | string | `"/callback"` | Path to `callbackUrl` which needs to be registered at the Identity Provider. Pre-defined route in `VirtualService`. |
| istio.destinationRule.spec.trafficPolicy.tls.mode | string | `"ISTIO_MUTUAL"` | trafficPolicy [ClientTLSSettings-TLSmode](https://istio.io/latest/docs/reference/config/networking/destination-rule/#ClientTLSSettings-TLSmode) |
| istio.enabled | bool | `true` | Enables mtls per workload (pod) |
| istio.peerAuthentication.spec.mtls.mode | string | `"STRICT"` | mTLS mode for istio. [PeerAuthentication-MutualTLS-Mode](https://istio.io/latest/docs/reference/config/security/peer_authentication/#PeerAuthentication-MutualTLS-Mode) |
| service.spec.ports.http.port | string | `"80"` | The http port the service is exposed to in the cluster. |
| service.spec.ports.http.targetPort | string | `"80"` | The http port the service listens to and to which requests will be sent. |
| service.spec.ports.https.port | string | `"443"` | The https port the service is exposed to in the cluster. |
| service.spec.ports.https.targetPort | string | `"443"` | The http port the service listens to and to which requests will be sent. |
| service.spec.type | string | `"ClusterIP"` | Specify what kind of service to deploy. See [Kubernetes Service Spec](https://kubernetes.io/docs/concepts/services-networking/service/) for details |
