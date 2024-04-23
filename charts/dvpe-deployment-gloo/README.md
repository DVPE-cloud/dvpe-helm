# dvpe-deployment-gloo

![Version: 5.1.0](https://img.shields.io/badge/Version-5.1.0-informational?style=flat-square)

Deprecated by Q4/24! Helm chart for installing microservices as gloo enabled VirtualService definitions.

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
  with `<client_id>` equals to the value (UUID) given as `gloo.authConfig.spec.configs.oauth.clientId`.
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
| additionalparameters | object | `{"configMapApplied":false,"customConfigMapReference":null,"secrets":{},"yamlConfigFileApplied":false}` | -----------------------------------# |
| additionalparameters.configMapApplied | bool | `false` | Set to `true` if you want to add a custom `ConfigMap` for your deployment. |
| additionalparameters.secrets | object | `{}` | Object in the format { <environmentVariable>: secretKeyRef: { name: "", key: "" }, <environmentVariable>: secretKeyRef: { nameRef: "", key: "" }, ...} to reference existing secrets and inject them as environment variables. The first secret name (given with "name") gets prefixed by "$Release.Name". The second secret name (given with "nameRef") will be used as is. |
| additionalparameters.yamlConfigFileApplied | bool | `false` | Set to `true` if you want to add a custom yaml configuration for your deployment. |
| autoscaling | object | `{"enabled":true,"maxReplicas":5,"metrics":{"resource":{"cpu":{"targetAverageUtilization":100},"memory":{"targetAverageUtilization":null}}},"minReplicas":1}` | ------------------------------# |
| autoscaling.enabled | bool | `true` | Enables `Horizontal Pod Autoscaler (HPA)` to control the replicas. If it is enabled, the replicas will be removed from the deployment. |
| autoscaling.maxReplicas | int | `5` | Defines `maxReplicas` of Pods scaled automatically by Horizontal Pod Autoscaler (HPA). |
| autoscaling.metrics.resource.cpu.targetAverageUtilization | int | `100` | Defines cpu utilization threshold in % for the HPA to scale up new pods. |
| autoscaling.metrics.resource.memory.targetAverageUtilization | string | `nil` | Defines memory utilization threshold in % for the HPA to scale up new pods. |
| autoscaling.minReplicas | int | `1` | Defines `minReplicas` of Pods scaled automatically by Horizontal Pod Autoscaler (HPA). |
| certificate | object | `{"cardsParameters":{"appdId":null,"caType":null,"department":null,"itsmService":null,"teamEmail":null,"userEmail":null,"userId":null},"create":true,"issuerRef":{"kind":"ClusterIssuer","name":"wadtfy-cluster-issuer"}}` | Defines details about the certificate. The domains for which the certificate will be issued are defined in the `gloo.virtualservice.spec.virtualHost.domains` field. |
| certificate.cardsParameters | object | `{"appdId":null,"caType":null,"department":null,"itsmService":null,"teamEmail":null,"userEmail":null,"userId":null}` | Parameters needed by CARDS API for certificate creation. They may be optional if specified in the referenced Issuer. |
| certificate.cardsParameters.appdId | string | `nil` | Application Deployment ID. It's the one that starts with `APPD-`. |
| certificate.cardsParameters.caType | string | `nil` | CA Type. Possible values are `Internal` for internal certificates or `External` for global public certificates. |
| certificate.cardsParameters.department | string | `nil` | Department. Used to identify the department the issued certificate belongs to. |
| certificate.cardsParameters.itsmService | string | `nil` | ITSM Service. Used to identify the ITSM service the issued certificate belongs to. |
| certificate.cardsParameters.teamEmail | string | `nil` | Team Email. Used to send notifications about the certificate to. |
| certificate.cardsParameters.userEmail | string | `nil` | User Email of the person requesting the certificate. Can be the same as teamEmail. Used to send notifications about the certificate to. |
| certificate.cardsParameters.userId | string | `nil` | User ID of the person requesting the certificate. Can also be a technical user. |
| certificate.issuerRef | object | `{"kind":"ClusterIssuer","name":"wadtfy-cluster-issuer"}` | Reference to issuer to use for certificate creation. Defaults to wadtfy-cluster-issuer ClusterIssuer which does not define any default values. |
| certificate.issuerRef.kind | string | `"ClusterIssuer"` | Kind of the issuer to use for certificate creation. Usually "Issuer" or "ClusterIssuer". |
| certificate.issuerRef.name | string | `"wadtfy-cluster-issuer"` | Name of the issuer to use for certificate creation. |
| datadog | object | `{"enabled":true,"env":"none","logProcessingRules":null,"source":null,"team":null,"version":null}` | -----------------------------------# |
| datadog.enabled | bool | `true` | When set to true Datadog is enabled and all logs, metrics and traces will be sent to Datadog. |
| datadog.env | string | `"none"` | Label in Datadog for the target environment - e.g. test, int, prod or an abbreviated k8s cluster name. |
| datadog.source | string | `nil` | Defines the source which creates log outputs. Source defines the log format and triggers Datadog parser pipelines |
| datadog.team | string | `nil` | Label in Datadog for the responsible team |
| datadog.version | string | `nil` | Label in Datadog for the service version. If undefined, the value of `deployment.spec.image.tag` is used. This value should not be set by ordinary deployments. It is intended for special cases (e.g. CI triggered deployments). |
| deployment | object | `{"podAnnotations":{},"spec":{"containers":{"livenessProbe":{},"readinessProbe":{},"startupProbe":{}},"image":{"name":null,"pullPolicy":"IfNotPresent","repository":null,"tag":"latest"},"imagePullSecrets":"docker-reg-secret","labels":{},"replicas":1,"resources":{"limits":{"cpu":null,"memory":null},"requests":{"cpu":"150m","memory":"200M"}},"securityContext":{"groupId":null,"userId":null},"serviceAccountName":null}}` | -----------------------------# |
| deployment.podAnnotations | object | `{}` | Object of additional `podAnnotations`. |
| deployment.spec.containers.livenessProbe | object | `{}` | Configuration of LivenessProbe as documented here: [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| deployment.spec.containers.readinessProbe | object | `{}` | Configuration of ReadinessProbe as documented here: [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| deployment.spec.containers.startupProbe | object | `{}` | Configuration of StartupProbe as documented here: [Configure Liveness, Readiness and Startup Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) |
| deployment.spec.image.name | string | `nil` | The image name to use. |
| deployment.spec.image.pullPolicy | string | `"IfNotPresent"` | The default rule for downloading images. |
| deployment.spec.image.repository | string | `nil` | The docker repository to pull the service image from. |
| deployment.spec.image.tag | string | `"latest"` | The image version to use. |
| deployment.spec.imagePullSecrets | string | `"docker-reg-secret"` | Image Pull Secret to access docker registry. |
| deployment.spec.labels | object | `{}` | Labels to be added to the deployment and the pods. |
| deployment.spec.replicas | int | `1` | The number of service instances to deploy. Will be ignored when autoscaling.enabled is true |
| deployment.spec.resources.limits.cpu | string | `nil` | Total amount of CPU time that a container can use every 100 ms. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.limits.memory | string | `nil` | The memory limit for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.requests.cpu | string | `"150m"` | Fractional amount of CPU allowed for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.resources.requests.memory | string | `"200M"` | Amount of memory reserved for a Pod. See [Managing Compute Resources for Containers](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/) for a detailed description on resource usage. |
| deployment.spec.securityContext.groupId | string | `nil` | The Group ID number of process running inside the container. |
| deployment.spec.securityContext.userId | string | `nil` | The User ID number of process running inside the container. |
| deployment.spec.serviceAccountName | string | `nil` | The ServiceAccount this service will be associated with. If empty, `serviceAccountName` will be `<namespace>-sa` |
| externalSecrets | object | `{"oauth2":{"key":null},"service":{"key":null,"refreshInterval":"15m"}}` | -----------------------------# |
| externalSecrets.oauth2.key | string | `nil` | `Key` to AWS Secret Manager object where the client secret for OAuth2 provider should be stored. The key in the Secret Manager Object has to be named as the given `gloo.authConfig.spec.configs.oauth2.clientId`. The value has to be formatted as `clientSecret: <secret>`. **This definition is exclusive to `gloo.authConfig.spec.configs.oauth.clientSecretRef`. If defined, `gloo.authConfig.spec.configs.oauth.clientSecretRef` is ignored.** |
| externalSecrets.service.key | string | `nil` | `Key` to AWS Secret Manager object where all sensitive application data should be stored. Each key in the Secret Manager Object should be named like your needed environment variable |
| externalSecrets.service.refreshInterval | string | `"15m"` | `refreshInterval` set the sync time range from AWS Secret Manager. Default is set to 15m |
| gloo | object | `{"authConfig":{"name":"auth-plugin","namespace":null,"spec":{"configs":{"additionalPlugins":null,"authExtensionPlugin":{"config":{"enableAccessTokenForwarding":false,"enableJwtContentForwarding":false,"enableQAccountMatching":false,"enableSubjectForwarding":false,"enableUserInfoForwarding":false,"grpcAddress":"auth-passthrough-extension.gloo-system.svc.cluster.local:9001","oidcUrl":null},"enabled":false},"authInterceptorPlugin":{"config":{"grpcAddress":"auth-passthrough-oauth-session-interceptor.gloo-system.svc.cluster.local:9001","oidcUrl":null},"enabled":false},"clientCredentialsPlugin":{"config":{"allowedClientIds":[],"grpcAddress":"auth-passthrough-client-credentials.gloo-system.svc.cluster.local:9001","oidcUrl":null},"enabled":false},"oauth":{"cache":{"cookieName":"auth0-session","enabled":true,"host":"redis.gloo-system.svc.cluster.local:6379"},"clientId":null,"clientSecretRef":{"name":"webeam-oidc","namespace":null},"cookieDomain":null,"enabled":false,"issuerUrl":null,"maxAge":0,"sameSite":0,"scopes":[],"strongAuthenticationLevel":null},"tokenValidationPlugin":{"config":{"allowedClientIds":null,"grpcAddress":"auth-passthrough-token-validation.gloo-system.svc.cluster.local:9001","oidcUrl":null,"strongAuthenticationLevel":null},"enabled":false}}}},"enabled":true,"ingress":{"scope":null},"upstream":{"fds":false},"virtualservice":{"spec":{"sslConfig":{"minimumProtocolVersion":"TLSv1_2","secretRef":{"name":null,"namespace":null}},"virtualHost":{"cors":{"allowCredentials":false,"allowHeaders":["origin"],"allowMethods":["GET","POST","PUT","DELETE"],"allowOrigin":[],"allowSubdomain":[],"exposeHeaders":["origin"],"maxAge":"1d"},"domains":[],"enableCsrf":false,"responseHeadersToAdd":[{"name":"X-Content-Type-Options","value":"nosniff"},{"name":"Strict-Transport-Security","value":"max-age=31536000; includeSubDomains"},{"name":"Content-Security-Policy","value":"frame-ancestors 'self' *.bmwgroup.net *.bmw.com;"}],"routes":{"additionalRoutes":[],"appPath":"/api","appPathRewrite":null,"appPathTimeout":null,"appPathWithAuthConfig":true,"callbackUrlPath":null,"rootPath":{"authConfigName":null,"timeout":null,"upstream":null,"withAuthConfig":false},"swagger":{"alternativePath":"/docs","enabled":false,"path":"/swagger-ui.html"}}}}}}` | -----------------------------------# |
| gloo.authConfig | object | `{"name":"auth-plugin","namespace":null,"spec":{"configs":{"additionalPlugins":null,"authExtensionPlugin":{"config":{"enableAccessTokenForwarding":false,"enableJwtContentForwarding":false,"enableQAccountMatching":false,"enableSubjectForwarding":false,"enableUserInfoForwarding":false,"grpcAddress":"auth-passthrough-extension.gloo-system.svc.cluster.local:9001","oidcUrl":null},"enabled":false},"authInterceptorPlugin":{"config":{"grpcAddress":"auth-passthrough-oauth-session-interceptor.gloo-system.svc.cluster.local:9001","oidcUrl":null},"enabled":false},"clientCredentialsPlugin":{"config":{"allowedClientIds":[],"grpcAddress":"auth-passthrough-client-credentials.gloo-system.svc.cluster.local:9001","oidcUrl":null},"enabled":false},"oauth":{"cache":{"cookieName":"auth0-session","enabled":true,"host":"redis.gloo-system.svc.cluster.local:6379"},"clientId":null,"clientSecretRef":{"name":"webeam-oidc","namespace":null},"cookieDomain":null,"enabled":false,"issuerUrl":null,"maxAge":0,"sameSite":0,"scopes":[],"strongAuthenticationLevel":null},"tokenValidationPlugin":{"config":{"allowedClientIds":null,"grpcAddress":"auth-passthrough-token-validation.gloo-system.svc.cluster.local:9001","oidcUrl":null,"strongAuthenticationLevel":null},"enabled":false}}}}` | -----------------------------------# |
| gloo.authConfig.name | string | `"auth-plugin"` | Prefix of the `Auth Config Plugin`. Final name will be <prefix>-<service-name> |
| gloo.authConfig.namespace | string | `nil` | Namespace where the `Auth Config Plugin` is located. If empty, release namespace is used. |
| gloo.authConfig.spec.configs.additionalPlugins | string | `nil` | List of plugins which should be added to the plugin chain. Expected format is a valid yaml with the `pluginAuth`. See [gloo Plugin Auth](https://docs.solo.io/gloo/latest/guides/security/auth/extauth/plugin_auth/#create-an-authconfig-resource) for details |
| gloo.authConfig.spec.configs.authExtensionPlugin.config.enableAccessTokenForwarding | bool | `false` | `enableAccessTokenForwarding` is a flag which tells whether the access_token should be forwarded or not |
| gloo.authConfig.spec.configs.authExtensionPlugin.config.enableJwtContentForwarding | bool | `false` | `enableJwtContentForwarding` is a flag which tells whether the user roles should be forwarded or not |
| gloo.authConfig.spec.configs.authExtensionPlugin.config.enableQAccountMatching | bool | `false` | `enableQAccountMatching` is a flag which forwards the user id (q-number) to the upstream. Only relevant if the user is using a different user id (e.g. c-number) for logging |
| gloo.authConfig.spec.configs.authExtensionPlugin.config.enableSubjectForwarding | bool | `false` | `enableSubjectForwarding` is a flag which tells whether the subject (q-number) should be forwarded or not |
| gloo.authConfig.spec.configs.authExtensionPlugin.config.enableUserInfoForwarding | bool | `false` | `enableUserInfoForwarding` is a flag which tells whether the user roles should be forwarded or not |
| gloo.authConfig.spec.configs.authExtensionPlugin.config.grpcAddress | string | `"auth-passthrough-extension.gloo-system.svc.cluster.local:9001"` | `grpcAddress`  - where the access token can be verified at the IDP |
| gloo.authConfig.spec.configs.authExtensionPlugin.config.oidcUrl | string | `nil` | `oidcUrl`  - where the access token can be verified at the IDP |
| gloo.authConfig.spec.configs.authExtensionPlugin.enabled | bool | `false` | If `enabled` set to true the auth code flow extension plugin will be used |
| gloo.authConfig.spec.configs.authInterceptorPlugin.config.oidcUrl | string | `nil` | `oidcUrl` for exchanging / terminating already valid sessions |
| gloo.authConfig.spec.configs.authInterceptorPlugin.enabled | bool | `false` | If `enabled` set to true the interceptor plugin will be used; Use this plugin to stop login sessions to force relogin (e.g. for 2FA) |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.allowedClientIds | list | `[]` | `allowedClientIds` **list (NOT string!)** of ids that are allowed by the plugin. If not given at all, all clients are allowed. If [], then no client is allowed. If [a, b], then a, b are allowed |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.config.oidcUrl | string | `nil` | `oidcUrl`  - where the access token can be verified at the IDP |
| gloo.authConfig.spec.configs.clientCredentialsPlugin.enabled | bool | `false` | If `enabled` set to true the machine to machine plugin will be used |
| gloo.authConfig.spec.configs.oauth.cache.cookieName | string | `"auth0-session"` | `CookieName` of the session cookie. Need to be `auth0-session` otherwise the TokenValidation plugin will not validate the cookie |
| gloo.authConfig.spec.configs.oauth.cache.enabled | bool | `true` | If `enabled` set to true the Gloo redis cache will be used |
| gloo.authConfig.spec.configs.oauth.cache.host | string | `"redis.gloo-system.svc.cluster.local:6379"` | Redis `host`. |
| gloo.authConfig.spec.configs.oauth.clientId | string | `nil` | Registered `ClientID` at the IDP |
| gloo.authConfig.spec.configs.oauth.clientSecretRef.name | string | `"webeam-oidc"` | Name of the `Secret`. Gloo expects a k8s secret with the key `oauth` and base64 encoded value `clientSecret: secretValue` **This value is ignored if `externalSecrets.oidc.key` is present.** |
| gloo.authConfig.spec.configs.oauth.clientSecretRef.namespace | string | `nil` | Namespace were the `Secret` is located. If empty, release namespace is used. **This value is ignored if `externalSecrets.oidc.key` is present.** |
| gloo.authConfig.spec.configs.oauth.cookieDomain | string | `nil` | The domain to be used for `id_token`, `access_token` or `auth0-session` cookies set after successful authentication. This has to be some kind of wildcard to support cross origin requests. If unset, the cookies get no domain set. |
| gloo.authConfig.spec.configs.oauth.enabled | bool | `false` | If `enabled` set to true the oauth plugin from Gloo will be used |
| gloo.authConfig.spec.configs.oauth.issuerUrl | string | `nil` | Issuer URL to the Identity Provider. Gloo adds `.well-known/openid-configuration` to the url automatically |
| gloo.authConfig.spec.configs.oauth.maxAge | int | `0` | The `maxAge` of the session cookie. Gloo will use the `maxAge` as TTL in Redis as well .If set to `0` the cookie is valid for the existing browser session. |
| gloo.authConfig.spec.configs.oauth.sameSite | int | `0` | The `sameSite` cookie property for restricting the site context. The default is set to 0 and will be ignored. Users of this property can overwrite this setting with numeric values according to https://docs.solo.io/gloo-network/latest/reference/api/auth_config/#usersession-cookieoptions-samesite. |
| gloo.authConfig.spec.configs.oauth.scopes | list | `[]` | List of OIDC scopes. `openid` is set per default by Gloo and must not be added here |
| gloo.authConfig.spec.configs.oauth.strongAuthenticationLevel | string | `nil` | The strong authentication level. Possible values are: 4000, 7000. If not set, there is no strong authentication. |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.allowedClientIds | string | `nil` | `allowedClientIds` **list (NOT string!)** of ids that are allowed by the plugin. If not given at all, all clients are allowed. If [], then no client is allowed. If [a, b], then a, b are allowed |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.oidcUrl | string | `nil` | `oidcUrl` where the access token can be verified at the IDP |
| gloo.authConfig.spec.configs.tokenValidationPlugin.config.strongAuthenticationLevel | string | `nil` | The strong authentication level. Possible values are: 4000, 7000. If not set, there is no strong authentication. |
| gloo.authConfig.spec.configs.tokenValidationPlugin.enabled | bool | `false` | If `enabled` set to true the backend plugin will be used |
| gloo.enabled | bool | `true` | When set to true only the application's deployment resources will be installed with this chart. Can be used to explicitly avoid deploying a VirtualService resource. |
| gloo.ingress.scope | string | `nil` | Signals Gloo which Gateway Proxy to use for deploying a Virtual Service into. Value must be one of `private` for intranet- or `public` for internet-deployment. |
| gloo.upstream | object | `{"fds":false}` | -----------------------------------# |
| gloo.upstream.fds | bool | `false` | Whitelist this upstream for `FDS`. [Gloo Function Discovery Mode] (https://docs.solo.io/gloo-edge/latest/installation/advanced_configuration/fds_mode/) |
| gloo.virtualservice | object | `{"spec":{"sslConfig":{"minimumProtocolVersion":"TLSv1_2","secretRef":{"name":null,"namespace":null}},"virtualHost":{"cors":{"allowCredentials":false,"allowHeaders":["origin"],"allowMethods":["GET","POST","PUT","DELETE"],"allowOrigin":[],"allowSubdomain":[],"exposeHeaders":["origin"],"maxAge":"1d"},"domains":[],"enableCsrf":false,"responseHeadersToAdd":[{"name":"X-Content-Type-Options","value":"nosniff"},{"name":"Strict-Transport-Security","value":"max-age=31536000; includeSubDomains"},{"name":"Content-Security-Policy","value":"frame-ancestors 'self' *.bmwgroup.net *.bmw.com;"}],"routes":{"additionalRoutes":[],"appPath":"/api","appPathRewrite":null,"appPathTimeout":null,"appPathWithAuthConfig":true,"callbackUrlPath":null,"rootPath":{"authConfigName":null,"timeout":null,"upstream":null,"withAuthConfig":false},"swagger":{"alternativePath":"/docs","enabled":false,"path":"/swagger-ui.html"}}}}}` | -----------------------------------# |
| gloo.virtualservice.spec.sslConfig.minimumProtocolVersion | string | `"TLSv1_2"` | Value of the minimum TLS protocol version. Accepted values are: TLSv1_2, TLSv1_3. |
| gloo.virtualservice.spec.sslConfig.secretRef.name | string | `nil` | Name of the secret containing the certificate information for this deployment. |
| gloo.virtualservice.spec.sslConfig.secretRef.namespace | string | `nil` | Namespace where the secret is located. If empty, gloo namespace is used. |
| gloo.virtualservice.spec.virtualHost.cors.allowCredentials | bool | `false` | Specifies the Access-Control-Allow-Credentials header. Value is `false` by default for security reasons. |
| gloo.virtualservice.spec.virtualHost.cors.allowHeaders | list | `["origin"]` | Specifies the content for the `access-control-allow-headers` header. In general this should not be changed. |
| gloo.virtualservice.spec.virtualHost.cors.allowMethods | list | `["GET","POST","PUT","DELETE"]` | Specifies the HTTP methods to allow CORS for. |
| gloo.virtualservice.spec.virtualHost.cors.allowOrigin | list | `[]` | Specifies the URLs of origins to allow CORS for. Origin URLs have to contain scheme, domain and port (if none-standard port is used). |
| gloo.virtualservice.spec.virtualHost.cors.allowSubdomain | list | `[]` | Specifies the sub domains of origins to allow CORS for. The sub somain has to be given as URL containing scheme, sub domain and port (if none-standard port is used) - e.g. https://bmwgroup.net:8443. |
| gloo.virtualservice.spec.virtualHost.cors.exposeHeaders | list | `["origin"]` | Specifies the content for the `access-control-expose-headers` header. In general this should not be changed. |
| gloo.virtualservice.spec.virtualHost.cors.maxAge | string | `"1d"` | Specifies the content for the `access-control-max-age` header. In general this should not be changed. |
| gloo.virtualservice.spec.virtualHost.domains | list | `[]` | **String (Deprecated) or List** of `DNS domain names` this service will be published to. *Note:* This domain will also be used for the `callbackUrl`. If multiple domains are given, the first one will be used. |
| gloo.virtualservice.spec.virtualHost.enableCsrf | bool | `false` | Enable protection against CSRF (recommended for applications having front-end and back-end) |
| gloo.virtualservice.spec.virtualHost.responseHeadersToAdd | list | `[{"name":"X-Content-Type-Options","value":"nosniff"},{"name":"Strict-Transport-Security","value":"max-age=31536000; includeSubDomains"},{"name":"Content-Security-Policy","value":"frame-ancestors 'self' *.bmwgroup.net *.bmw.com;"}]` | Map which specifies additional response headers which have to be added to every response of the VirtualHost. In general this map might be extended but the default values should not be removed as they are necessary for security reasons. |
| gloo.virtualservice.spec.virtualHost.routes.additionalRoutes | list | `[]` | List of route configurations for this `VirtualService`. See [gloo VirtualService Specification](https://docs.solo.io/gloo-edge/latest/introduction/architecture/concepts/#virtual-services) for details |
| gloo.virtualservice.spec.virtualHost.routes.appPath | string | `"/api"` | Path to `appUrl` where the service can be accessed. Pre-defined route in `VirtualService`. |
| gloo.virtualservice.spec.virtualHost.routes.appPathRewrite | string | `nil` | `prefixRewrite` of the appPath. If empty no rewrite is set. |
| gloo.virtualservice.spec.virtualHost.routes.appPathWithAuthConfig | bool | `true` | If set to `true` the app path is secured with the default authConfig. |
| gloo.virtualservice.spec.virtualHost.routes.callbackUrlPath | string | `nil` | Path to `callbackUrl` which needs to be registered at the Identity Provider. Pre-defined route in `VirtualService`. |
| gloo.virtualservice.spec.virtualHost.routes.rootPath.authConfigName | string | `nil` | Name of the `auth config` for the secured root path. If not set, default auth config will be used. |
| gloo.virtualservice.spec.virtualHost.routes.rootPath.timeout | string | `nil` | Custom timeout for requests to rootPath. For example `60s`, [Valid units](https://pkg.go.dev/time#Duration). |
| gloo.virtualservice.spec.virtualHost.routes.rootPath.upstream | string | `nil` | Name of the `upstream` for the root path. This path will be only created if the appPath is not the rootPath. |
| gloo.virtualservice.spec.virtualHost.routes.rootPath.withAuthConfig | bool | `false` | If set to `true` the root path is secured with the default authConfig. |
| gloo.virtualservice.spec.virtualHost.routes.swagger.alternativePath | string | `"/docs"` | Alternative path to Swagger UI, this redirects to `...swagger.path`. |
| gloo.virtualservice.spec.virtualHost.routes.swagger.enabled | bool | `false` | If set to `true` routing for `...swagger.path` and `...swagger.alternativePath` gets enabled. |
| gloo.virtualservice.spec.virtualHost.routes.swagger.path | string | `"/swagger-ui.html"` | Path to `swagger-ui.html` page. |
| istio | object | `{"destinationRule":{"spec":{"trafficPolicy":{"tls":{"mode":"ISTIO_MUTUAL"}}}},"enabled":true,"peerAuthentication":{"spec":{"mtls":{"mode":"STRICT"}}}}` | -----------------------------------# |
| istio.destinationRule.spec.trafficPolicy.tls.mode | string | `"ISTIO_MUTUAL"` | trafficPolicy [ClientTLSSettings-TLSmode](https://istio.io/latest/docs/reference/config/networking/destination-rule/#ClientTLSSettings-TLSmode) |
| istio.enabled | bool | `true` | Enables mtls per workload (pod) |
| istio.peerAuthentication.spec.mtls.mode | string | `"STRICT"` | mTLS mode for istio. [PeerAuthentication-MutualTLS-Mode](https://istio.io/latest/docs/reference/config/security/peer_authentication/#PeerAuthentication-MutualTLS-Mode) |
| service | object | `{"spec":{"ports":{"http":{"name":"http","port":"8080","protocol":"TCP","targetPort":""},"https":{"name":"https","port":"","protocol":"TCP","targetPort":""}},"type":"ClusterIP"}}` | -----------------------------# |
| service.spec.ports.http.name | string | `"http"` | Name of the port within the service. If Istio is enabled, please check [Istio naming conventions](https://istio.io/latest/docs/ops/configuration/traffic-management/protocol-selection/#manual-protocol-selection) |
| service.spec.ports.http.port | string | `"8080"` | The http port the service is exposed to in the cluster. If no port is defined, port mapping is disabled. |
| service.spec.ports.http.protocol | string | `"TCP"` | The protocol the service accepts. Allowed protocols are UDP, TCP, or SCTP. |
| service.spec.ports.http.targetPort | string | `""` | The http port the service listens to and to which requests will be sent. If no `targetPort` is defined, port will be used. |
| service.spec.ports.https.name | string | `"https"` | Name of the port within the service. If Istio is enabled, please check [Istio naming conventions](https://istio.io/latest/docs/ops/configuration/traffic-management/protocol-selection/#manual-protocol-selection) |
| service.spec.ports.https.port | string | `""` | The https port the service is exposed to in the cluster. If no port is defined, port mapping is disabled. |
| service.spec.ports.https.protocol | string | `"TCP"` | The protocol the service accepts. Allowed protocols are UDP, TCP, or SCTP. |
| service.spec.ports.https.targetPort | string | `""` | The http port the service listens to and to which requests will be sent. If no `targetPort` is defined, port will be used. |
| service.spec.type | string | `"ClusterIP"` | Specify what kind of service to deploy. See [Kubernetes Service Spec](https://kubernetes.io/docs/concepts/services-networking/service/) for details |
