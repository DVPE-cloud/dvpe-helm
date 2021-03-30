# dvpe-deployment-gloo

![Version: 2.0.0](https://img.shields.io/badge/Version-2.0.0-informational?style=flat-square)

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

* (_deprecated - since version #1.3.0 this can be set up by the template via an [`ExternalSecret`](https://github.com/external-secrets/kubernetes-external-secrets) - see below_) a K8S secret with name `webeam-oidc` exists in the same namespace in which your service is going to be deployed.
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
      name: webeam-oidc
      namespace: argo-apps
    data:
      oauth: <yourClientSecret>
    EOF
    ```

* (_new since version #1.3.0_)
The `<webeam-oidc>` secret can be set up as an external secret charged from an AWS secrets manager one.
To use this feature, please sepecify `externalSecrets.oidc.key` as the name of the AWS secrets manager secret. This secret is expected in format:
    ```yaml
    {
      "<client_id>": "clientSecret: <client_secret>",
      ...
    }
    ```
  with `<client_id>` equals to the value (UUID) given as `gloo.authConfig.spec.configs.oauth.client_id`.
  The format allows multiple client IDs and secrets (e.g. for different services in a common business domain) to be defined within a single secrets manager secret.
  >**Note:**\
  >The name of the `<webeam-oidc>` secret gets changed to `<service-name>-oidc-secrets` to distinguish the secrets dedicated to different services deployed to
  >the same K8S namespace.

### Using config from a file:

```bash
helm install -f config.yaml --namespace `TARGET_K8S_NAMESPACE` `HELM_RELEASE_NAME` dvpe/dvpe-deployment-gloo
```
>**Note**:\
>The structure of `config.yaml` needs to adhere to the chart's value fields (see config section below). `config.yaml` can be defined as a default helm
>values file.

#### Notes on gloo VirtualService definitions

The `VirtualService` kind in gloo allows to define a set of routing rules to services deployed on K8S. A `VirtualService` always comes with an `Upstream`
automatically deployed in a pre-defined namespace on the cluster. An `Upstream` in turn specifies the destination to the service inside the cluster.
See [gloo concepts](https://docs.solo.io/gloo-edge/latest/introduction/architecture/concepts/#virtual-services) for further details.

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

For user interface services and services which provide a [Swagger](https://swagger.io/) API documentation an additional
`VirtualService` is generated to provide a HTTP to HTTPS redirect for user convenience. This is done for all services
which have either a `gloo.virtualservice.spec.virtualHost.routes.callbackUrlPath` value set or the
`gloo.virtualservice.spec.virtualHost.routes.swagger.enabled` switched on.
The first value is related to the OAuth flow with the IDP and thus a good indicator for an user interfaces service.
The second one switches on routing for the Swagger API documentation indicating the service to provide an according UI.
>**Note:**\
>For Swagger API documentation this redirect is limited to the paths given as `gloo.virtualservice.spec.virtualHost.routes.swagger.path` and
>`gloo.virtualservice.spec.virtualHost.routes.swagger.alternativePath`.

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
| datadog.env | string | `"none"` | Label in Datadog for the target environment - e.g. test, int, prod or an abbreviated k8s cluster name. |
| datadog.source | string | `nil` | Defines the source which creates log outputs. Source defines the log format and triggers Datadog parser pipelines |
| datadog.team | string | `nil` | Label in Datadog for the responsible team |
| datadog.version | string | `nil` | Label in Datadog for the service version. If undefined, the value of `deployment.spec.image.tag` is used. This value should not be set by ordinary deployments. It is intended for special cases (e.g. CI triggered deployments). |
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
| deployment.spec.serviceAccountName | string | `nil` | The ServiceAccount this service will be associated with. If empty, `serviceAccountName` will be `<namespace>-sa` |
| externalSecrets.oauth2.key | string | `nil` | `Key` to AWS Secret Manager object where the client secret for OAuth2 provider should be stored. The key in the Secret Manager Object has to be named as the given `gloo.authConfig.spec.configs.oauth.client_id`. The value has to be formatted as `clientSecret: <secret>`. **This definition is exclusive to `gloo.authConfig.spec.configs.oauth.client_secret_ref`. If defined, `gloo.authConfig.spec.configs.oauth.client_secret_ref` is ignored.** |
| externalSecrets.service.key | string | `nil` | `Key` to AWS Secret Manager object where all sensitive application data should be stored. Each key in the Secret Manager Object should be named like your needed environment variable |
| gloo.authConfig.name | string | `"auth-plugin"` | Prefix of the `Auth Config Plugin`. Final name will be <prefix>-<service-name> |
| gloo.authConfig.namespace | string | `nil` | Namespace where the `Auth Config Plugin` is located. If empty, release namespace is used. |
| gloo.authConfig.spec.configs.additionalPlugins | string | `nil` | List of plugins which should be added to the plugin chain. Expected format is a valid yaml with the `pluginAuth`. See [gloo Plugin Auth](https://docs.solo.io/gloo/latest/guides/security/auth/extauth/plugin_auth/#create-an-authconfig-resource) for details |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.allowedClientIds | string | `nil` | `allowedClientIds` **list (NOT string!)** of ids that are allowed by the plugin. If not given at all, all clients are allowed. If [], then no client is allowed. If [a, b], then a, b are allowed |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.cache.awsRegion | string | `nil` | `awsRegion` where the cache is located |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.cache.enabled | bool | `false` | if `enabled` is false, no cache is used |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.cache.tableName | string | `nil` | `tableName` of the auth cache |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.clientId | string | `nil` | `clientId` of the machine2machine client registered at the IDP |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.clientSecretRef.name | string | `"webeam-oidc"` | Name of the `Secret`. Gloo expects a k8s secret with the key `oauth` and base64 encoded value `clientSecret: secretValue` **This value is ignored if `externalSecrets.oidc.key` is present.** |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.clientSecretRef.namespace | string | `nil` | Namespace were the `Secret` is located. If empty, release namespace is used. **This value is ignored if `externalSecrets.oidc.key` is present.** |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.idpUrl | string | `nil` | `idpUrl`  - where the access token can be verified at the IDP |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.mode | string | `nil` | The AuthClientCredentials plugin can work in two modes: `GatherCredentials` and `VerifyAccessToken` |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.enabled | bool | `false` | If `enabled` set to true the machine to machine plugin will be used |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.name | string | `"AuthClientCredentials"` | `Name` of the auth client credentials plugin |
| gloo.authConfig.spec.configs.codeFlowExtensionPlugin.config.enableAccessTokenForwarding | bool | `false` | `enableAccessTokenForwarding` is a flag which tells whether the access_token should be forwarded or not |
| gloo.authConfig.spec.configs.codeFlowExtensionPlugin.config.enableSubjectForwarding | bool | `false` | `enableSubjectForwarding` is a flag which tells whether the subject (q-number) should be forwarded or not |
| gloo.authConfig.spec.configs.codeFlowExtensionPlugin.config.oidcUrl | string | `nil` | `oidcUrl`  - where the access token can be verified at the IDP |
| gloo.authConfig.spec.configs.codeFlowExtensionPlugin.enabled | bool | `false` | If `enabled` set to true the auth code flow extension plugin will be used |
| gloo.authConfig.spec.configs.codeFlowExtensionPlugin.name | string | `"AuthCodeFlowExtensionPlugin"` | `Name` of the auth code flow extension plugin |
| gloo.authConfig.spec.configs.oauth.client_id | string | `nil` | Registered `ClientID` at the IDP |
| gloo.authConfig.spec.configs.oauth.client_secret_ref.name | string | `"webeam-oidc"` | Name of the `Secret`. Gloo expects a k8s secret with the key `oauth` and base64 encoded value `clientSecret: secretValue` **This value is ignored if `externalSecrets.oidc.key` is present.** |
| gloo.authConfig.spec.configs.oauth.client_secret_ref.namespace | string | `nil` | Namespace were the `Secret` is located. If empty, release namespace is used. **This value is ignored if `externalSecrets.oidc.key` is present.** |
| gloo.authConfig.spec.configs.oauth.cookie_domain | string | `nil` | The domain to be used for `id_token` and `access_token` cookies set after successful authentication. This has to be some kind of wildcard to support cross origin requests. If unset, the cookies get no domain set. |
| gloo.authConfig.spec.configs.oauth.enabled | bool | `false` | If `enabled` set to true the oauth plugin from Gloo will be used |
| gloo.authConfig.spec.configs.oauth.issuer_url | string | `nil` | Issuer URL to the Identity Provider. Gloo adds `.well-known/openid-configuration` to the url automatically |
| gloo.authConfig.spec.configs.oauth.scopes | string | `nil` | List of OIDC scopes. `openid` is set per default by Gloo and must not be added here |
| gloo.authConfig.spec.configs.oauth.strongAuthenticationLevel | string | `nil` | The strong authentication level. Possible values are: 4000, 7000. If not set, there is no strong authentication. |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.allowedClientIds | string | `nil` | `allowedClientIds` **list (NOT string!)** of ids that are allowed by the plugin. If not given at all, all clients are allowed. If [], then no client is allowed. If [a, b], then a, b are allowed |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.cache.awsRegion | string | `"eu-west-1"` | `awsRegion` where the cache is located |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.cache.enabled | bool | `false` | if `enabled` is false, no cache is used |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.cache.tableName | string | `"auth-cache-prod"` | `tableName` of the auth cache |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.oidcUrl | string | `nil` | `oidcUrl` where the access token can be verified at the IDP |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.strongAuthenticationLevel | string | `nil` | The strong authentication level. Possible values are: 4000, 7000. If not set, there is no strong authentication. |
| gloo.authConfig.spec.configs.tokenValidationPlugin.enabled | bool | `false` | If `enabled` set to true the backend plugin will be used |
| gloo.authConfig.spec.configs.tokenValidationPlugin.name | string | `"AuthTokenValidation"` | `Name` of the auth token validation plugin |
| gloo.enabled | bool | `true` | When set to true only the application's deployment resources will be installed with this chart. Can be used to explicitly avoid deploying a VirtualService resource. |
| gloo.namespace | string | `"gloo-system"` | `Namespace` where all Gloo resources are deployed. |
| gloo.upstream.fds | bool | `false` | Whitelist this upstream for `FDS`. [Gloo Function Discovery Mode] (https://docs.solo.io/gloo-edge/latest/installation/advanced_configuration/fds_mode/) |
| gloo.upstream.namespace | string | `"gloo-system"` | `Namespace` where gloo upstream is deployed. |
| gloo.virtualservice.spec.sslConfig.secretRef.name | string | `"gloo-public-tls"` | Name of the secret containing the certificate information for this deployment. |
| gloo.virtualservice.spec.sslConfig.secretRef.namespace | string | `nil` | Namespace where the secret is located. If empty, gloo namespace is used. |
| gloo.virtualservice.spec.virtualHost.cors.allowHeaders | list | `["origin"]` | Specifies the content for the `access-control-allow-headers` header. In general this should not be changed. |
| gloo.virtualservice.spec.virtualHost.cors.allowMethods | list | `["GET","POST","PUT","DELETE"]` | Specifies the HTTP methods to allow CORS for. |
| gloo.virtualservice.spec.virtualHost.cors.allowOrigin | string | `nil` | Specifies the URLs of origins to allow CORS for. Origin URLs have to contain scheme, domain and port (if none-standard port is used). |
| gloo.virtualservice.spec.virtualHost.cors.allowSubdomain | string | `nil` | Specifies the sub domains of origins to allow CORS for. The sub somain has to be given as URL containing scheme, sub domain and port (if none-standard port is used) - e.g. https://bmwgroup.net:8443. |
| gloo.virtualservice.spec.virtualHost.cors.exposeHeaders | list | `["origin"]` | Specifies the content for the `access-control-expose-headers` header. In general this should not be changed. |
| gloo.virtualservice.spec.virtualHost.cors.maxAge | string | `"1d"` | Specifies the content for the `access-control-max-age` header. In general this should not be changed. |
| gloo.virtualservice.spec.virtualHost.domains | string | `nil` | `DNS domain name` this service will be published to. |
| gloo.virtualservice.spec.virtualHost.routes.additionalRoutes | string | `nil` | List of route configurations for this `VirtualService`. See [gloo VirtualService Specification](https://docs.solo.io/gloo-edge/latest/introduction/architecture/concepts/#virtual-services) for details |
| gloo.virtualservice.spec.virtualHost.routes.appPath | string | `"/api"` | Path to `appUrl` where the service can be accessed. Pre-defined route in `VirtualService`. |
| gloo.virtualservice.spec.virtualHost.routes.callbackUrlPath | string | `nil` | Path to `callbackUrl` which needs to be registered at the Identity Provider. Pre-defined route in `VirtualService`. |
| gloo.virtualservice.spec.virtualHost.routes.swagger.alternativePath | string | `"/docs"` | Alternative path to Swagger UI, this redirects to `...swagger.path`. |
| gloo.virtualservice.spec.virtualHost.routes.swagger.enabled | bool | `false` | If set to `true` routing for `...swagger.path` and `...swagger.alternativePath` gets enabled. |
| gloo.virtualservice.spec.virtualHost.routes.swagger.path | string | `"/swagger-ui.html"` | Path to `swagger-ui.html` page. |
| istio.destinationRule.spec.trafficPolicy.tls.mode | string | `"ISTIO_MUTUAL"` | trafficPolicy [ClientTLSSettings-TLSmode](https://istio.io/latest/docs/reference/config/networking/destination-rule/#ClientTLSSettings-TLSmode) |
| istio.enabled | bool | `true` | Enables mtls per workload (pod) |
| istio.peerAuthentication.spec.mtls.mode | string | `"STRICT"` | mTLS mode for istio. [PeerAuthentication-MutualTLS-Mode](https://istio.io/latest/docs/reference/config/security/peer_authentication/#PeerAuthentication-MutualTLS-Mode) |
| service.spec.ports.http.port | string | `"80"` | The http port the service is exposed to in the cluster. |
| service.spec.ports.http.targetPort | string | `"80"` | The http port the service listens to and to which requests will be sent. |
| service.spec.ports.https.port | string | `"443"` | The https port the service is exposed to in the cluster. |
| service.spec.ports.https.targetPort | string | `"443"` | The http port the service listens to and to which requests will be sent. |
| service.spec.type | string | `"ClusterIP"` | Specify what kind of service to deploy. See [Kubernetes Service Spec](https://kubernetes.io/docs/concepts/services-networking/service/) for details |
