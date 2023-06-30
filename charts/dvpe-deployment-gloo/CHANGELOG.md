# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [Unreleased]

## [4.4.0]
### Changed
- Naming of SecretStore reference in ExternalSecret has been changed according to Crossplane spec. The new naming convention is: `secret-store-<NAMESPACE_NAME>`

## [4.3.0]
### Changed
- Naming of SecretStore reference in ExternalSecret has been changed according to Crossplane spec. The new naming convention is: `secret-store-<PRODUCT_NAME>-<NAMESPACE_NAME>`

## [4.2.0]
### Added
- New cookie property sameSite added in default AuthConfig

## [4.1.0]
### Changed
- Deployment now fully supports all probes of type `startupProbe`, `livenessProbe` and `readinessProbe`. Now not only
  http probes but everything which Kubernetes offers.
- `livenessProbe.enabled` has been removed. LivenessProbe will be added if there are corresponding values defined.
- All probes are now optional.

## [4.0.0]

### **Breaking Changes**

* The old External Secret CRD's are not supported anymore.
From Version 4.0.0 of `dvpe-deployment-gloo` onwards the ExternalSecrets are switched to new Kubernetes kinds.
The Kubernetes secrets deployment has changed and will generate new Kubernetes Resource Kinds (external-secrets.io/v1beta1).

INFO: To use the 4.0.0 Version you need an AWS SecretStore in **your** AWS account.
The ExternalSecretStore reference will generated on Namespace generation by WADTFY automatism. 

* Parameter changes
  - removed `externalSecrets.service.roleArn` (not required anymore with new SecretStores per Namespace)
  - added `externalSecrets.service.refreshInterval` to control the refresh/sync interval from ExternalSecrets Operator. Default is set to 15 minutes.
  The new Chart Version with new Secret Generator is only available after upgrade to ExternalSecret Version 0.7 (https://external-secrets.io/). It does not work with old Kubernetes External Secrets (https://github.com/external-secrets/kubernetes-external-secrets)

## [3.2.4]
### Added
* LivenessProbe in deployment.yaml as optional property

## [3.2.3]
### Bugfix
* Removed duplicate envFrom property in deployment.

## [3.2.2]
### Added
* possibility to reference a additional (global) configmap with parameter additionalparameter.customConfigMapReference to application container

## [3.2.1]
### Added
* Extension for projects with Crossplane generated AWS resources.
  CI/CD deployments of such projects (till now) always have per-branch generated resources - which ordinarily is OK, but not always.
  This extension has nothing to do with Crossplane itself, but it introduces referencing of absolute named secrets to
  read additional parameters from.
  In prior a given secret name was always prefixed with the release name. A CI/CD deployment was never able to 
  reference the secret (containing the resource name) created by Crossplane for the origin (none branch) deployment.
  But exactly this would be required to share Crossplane generated resources among multiple branch deployments.
* To achieve the sharing `dvpe-deployment-gloo.additionalparameters.secrets.<ENV_VARIABLE_NAME>.secretKeyRef.nameRef` was added.
  It has precedence over `dvpe-deployment-gloo.additionalparameters.secrets.<ENV_VARIABLE_NAME>.secretKeyRef.name` and
  uses the given name of the secret as is instead of prefixing it with the release name.

## [3.2.0]
### Added
* `certificate.customIssuer` property for custom issuer selection with following options:
  * `internet` - cluster internet issuer
  * `intranet` - cluster intranet issuer
  * `other` - namespace issuer specified with `certificate.customIssuerSelector`
  * `none` - no issuer (equivalent of `useCustomIssuer: false`)
### Deprecated
* `certificate.useCustomIssuer`:
  * `true` - can be removed
  * `false` - use `customIssuer: none` instead

## [3.1.1]
### Fixed
* Allowed client ids are now created as list

## [3.1.0]
### Changed
* add support of injecting existing secrets
* remove support of creating new secrets

## [3.0.6]
### Changed
* Flag for user info forwarding
* Flag for JWT content forwarding

## [3.0.5]
### Changed
* added label for IngressScope to http-https-VirtualServices to proper assign all VirtualServices to the corresponding IngressGateways.

## [3.0.4]
### Changed
* added possibility to disable AuthPlugin in Rootpath

## [3.0.3]
### Removed
* Remove `argo` label from certificate resource (introduced in `3.0.2`)

## [3.0.2]
### Changed
* Link generated certificate (secret) with argo project

## [3.0.1]
### Fixed
* Update Client Credentials plugin to Gloo passthrough mechanism

## [3.0.0]
### Changed
* `templates/gloo_authConfigPlugin.yaml` has been adjusted according to requirements of new Gloo version 1.9.1.  
***Note: This is a breaking change. Only use this chart version if you migrated your projects using Gloo 1.9.1+***

## [2.3.8]
### Changed
* Support regexp path matcher in VirtualService

## [2.3.7]
### Added
* Add virutal service root path timeout 

## [2.3.6]
### Added
* Custom `AuthConfig` for root path
### Changed
* Remove default value for resources limits

## [2.3.5]
### Added
- Add a flag to the root path to secure the whole service with the default authConfig.
### Fixed
- Fix issue with scopes in authConfig
- Fix tls secret order in virtual service

## [2.3.4]
### Added
- support for Auth Interceptor Plugin. Plugin terminates existing login sessions and forces relogin, e.g. for login with 2FA.

## [2.3.3]
### Added
- Flag for enabling CSRF protection
- Condition for creating custom issuer resources
- Add roleArn parameter in external secrets for third-party accounts

## [2.3.2]
* Introduce new template with certificate details. Certificate will be created using internal certificate issuer.

## [2.2.2]
### Fixed
* PrefixRewrite indentation

## [2.2.1]

### Added
* Parameter to add a custom upstream to the root path if root path is not the app path
* PrefixRewrite for the appPath

## [2.2.0]

### Added 
* Gloo Redis cache is enabled and cookie maxAge can be set
* Changed TokenValidation and Extension plugin to passthrough mechanism

### Fixed
* Remove Istio SDS in Gloo upstream if Istio is not enabled
* Removed Gloo label in secret for the ClientCredentials flow
* Fixed VirutalService `additionalRoutes` order
* Fixed typos

## [2.1.0]

### Added
* Introduced new field `gloo.ingress.scope` which tells the Gloo VirtualService which of the existing Gateway Proxies to reference (public, private, cluster-internal).
* Added initial version of `values.schema.json` for parameter validation of `values.yaml` file.

## [2.0.6]

### Fixed
* Updated CHANGELOG.md and version conflicts. No functional changes included.

## [2.0.5]

### Fixed
* Fixed port mapping logic in service.yaml to only support either http or https mappings 

## [2.0.4]

### Fixed
* Remove replicas in the deployment.yaml when the HPA is enabled. Fixes an issue with the ArgoCD auto sync and the HPA (https://argoproj.github.io/argo-cd/user-guide/best_practices/#leaving-room-for-imperativeness).  

## [2.0.3]

### Fixed
* Typo in gloo virtual service domain attribute
* Enable virtual service for http-https redirect with multiple domains

## [2.0.2]

### Changed
* Enable List and String for VirtualService Domain.
* Helper Function to create authorizationCode.appUrl from the given Domain.

### Deprecated
* VirtualService Domain as String will not be supported in `3.0.0`

## [2.0.0] - 2021-04-07

### Added

* Extended CORS configuration support by adding  `gloo.virtualservice.spec.virtualHost.cors.allowSubdomain` value.

### Breaking Changes

* Gloo OAuth2 Plugins
  * Improve error handling
  * Secure handling of Client Secret
  * Ensure Two-Factor Authentication
  * Validate Client ID
  * Refactoring

## [1.3.1] - 2021-03-08

### Added

* Added tags `env`, `service` and `version` for DataDog according to [Unified Service Tagging](https://docs.datadoghq.com/getting_started/tagging/unified_service_tagging?tab=kubernetes).

## [1.3.0] - 2021-02-19

### Breaking Changes

* Changed swagger ui routing:
  * introduced `gloo.virtualservice.spec.virtualHost.routes.swagger.enabled` to switch on swagger ui routing
  * `gloo.virtualservice.spec.virtualHost.routes.swagger.rewriteUrl` was renamed to `.Values.gloo.virtualservice.spec.virtualHost.routes.swagger.alternativePath`
  * routing from `...swagger.alternativePath` to `...swagger.path` is done by HTTP redirect now because URL rewrite does not work due to a quirk in `springfox.js` which relies on the name `swagger-ui.html`.
* Added `gloo.authConfig.spec.configs.backendPlugin.config.jwksUrl` value. This has no default but is mandatory for each service using the `backendPlugin`.
* Reworked M2M authentication:
  * Renamed `gloo.authConfig.spec.configs.m2mPlugin.config.oidcUrl` to `gloo.authConfig.spec.configs.m2mPlugin.config.amBaseUrl` to match WebEAM naming.
  * Added `gloo.authConfig.spec.configs.m2mPlugin.config.mode` which has no default but is mandatory.
  * Reworked K8S resource (`AuthConfig`) to match the API of the latest `AuthM2m` plugin.

### Added

* Added support for CORS configuration of Gloo virtual services (`gloo.virtualservice.spec.virtualHost.cors`) according to [Gloo documentation: CORS](https://docs.solo.io/gloo-edge/latest/guides/security/cors/).
* K8S Secrets conaining the oauth client secrets for OIDC (known as `webeam-oidc` secrets) can now be generated by helm as [`ExternalSecret`](https://github.com/external-secrets/kubernetes-external-secrets) referencing to AWS secrets manager secrets.
* Added HTTP to HTTPS redirect by means of Gloo (see [Gloo documentation: HTTPS Redirect](https://docs.solo.io/gloo-edge/latest/guides/traffic_management/request_processing/https_redirect/)). This is done automatically for all deployments which have either a `gloo.virtualservice.spec.virtualHost.routes.callbackUrlPath` configured or `.Values.gloo.virtualservice.spec.virtualHost.routes.swagger.enabled` set to `true`. Such deployments are treated as user interfaces (or documentation interface) where a HTTP to HTTPS redirect should be provided for user convenience. In case of `...swagger.enabled` the redirect is limited to the paths defined as `...swagger.path` and `...swagger.alternativePath`.
* Added `gloo.authConfig.spec.configs.oauth.cookie_domain` to provide a domain to be used for authentication cookies (`it_token` and `access_token`). This value is required for UI services which execute cross origin requests to other services hosted by the platform - e.g. UI and its backend are hosted as separate services.
* Extended the generated `VirtualService` K8S Resources for Gloo by `sniDomains` (see [Serving certificates for multiple virtual hosts with SNI](https://docs.solo.io/gloo-edge/latest/guides/security/tls/server_tls/#serving-certificates-for-multiple-virtual-hosts-with-sni)).

### Removed

* Completely removed configuration of `SessionCache` plugin (`gloo.authConfig.spec.configs.cachePlugin` values) because this plugin is outdated and will be replaced.

## [1.2.2] - 2021-02-02

### Changed

* Blacklisting authentication path prefix (`gloo.virtualservice.spec.virtualHost.routes.appPath` and `gloo.virtualservice.spec.virtualHost.routes.callbackUrl`). 
* Enable FDS in Gloo Upstream to dectect gRPC functions

## [1.2.1] - 2021-01-13

### Added

* Add swagger ui routes options

### Removed

* Removed Gloo Function Discovery Service url path

## [1.2.0] - 2020-12-03

### Added

* Add Support for Gloo Function Discovery Service url path

## [1.1.0] - 2020-11-17

### Added

* Add Support for Machine to Machine Gloo Plugin
* Add Support for Backend Gloo Plugin to verify Access Tokens and Cookies
* Helpers Function for Service Account Name
* Small Refactoring and Fixes

## [1.0.0] - 2020-10-29

### Added

* Enable the use of Datadog
* Enable the use of External Secrets
* Add Gloo OAuth Plugin for Authorization Flow in UI's
* Add Gloo Virtual Service as Cluster Ingress
* Enable Istio for each deployed Pod
* Fix Linter Issues
* Small Refactoring and Fixes

## [0.0.2] - 2020-10-06

### Added

* Additional deployment flag to allow disabling VirtualService deployment 

## [0.0.1] - 2020-10-02

### Added

* Initial Version
* Contains K8S Resources: Deployment, Service, Secret, ConfigMap
* Contains gloo Resources: VirtualService

[0.0.1]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-0.0.1/charts/dvpe-deployment-gloo
[0.0.2]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-0.0.2/charts/dvpe-deployment-gloo
[1.0.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-1.0.0/charts/dvpe-deployment-gloo
[1.1.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-1.1.0/charts/dvpe-deployment-gloo
[1.2.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-1.2.0/charts/dvpe-deployment-gloo
[1.2.1]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-1.2.1/charts/dvpe-deployment-gloo
[1.2.2]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-1.2.2/charts/dvpe-deployment-gloo

[1.3.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-1.3.0/charts/dvpe-deployment-gloo
[1.3.1]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-1.3.1/charts/dvpe-deployment-gloo
[2.0.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.0.0/charts/dvpe-deployment-gloo
[2.0.2]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.0.2/charts/dvpe-deployment-gloo
[2.0.3]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.0.3/charts/dvpe-deployment-gloo
[2.0.4]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.0.4/charts/dvpe-deployment-gloo
[2.0.5]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.0.5/charts/dvpe-deployment-gloo
[2.0.6]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.0.6/charts/dvpe-deployment-gloo
[2.1.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.1.0/charts/dvpe-deployment-gloo
[2.2.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.2.0/charts/dvpe-deployment-gloo
[2.2.1]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.2.1/charts/dvpe-deployment-gloo
[2.2.2]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.2.2/charts/dvpe-deployment-gloo
[2.3.2]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.3.2/charts/dvpe-deployment-gloo
[2.3.3]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.3.3/charts/dvpe-deployment-gloo
[2.3.4]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.3.4/charts/dvpe-deployment-gloo
[2.3.5]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.3.5/charts/dvpe-deployment-gloo
[2.3.6]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.3.6/charts/dvpe-deployment-gloo
[2.3.7]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.3.7/charts/dvpe-deployment-gloo
[2.3.8]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-2.3.8/charts/dvpe-deployment-gloo
[3.0.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.0.0/charts/dvpe-deployment-gloo
[3.0.1]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.0.1/charts/dvpe-deployment-gloo
[3.0.2]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.0.2/charts/dvpe-deployment-gloo
[3.0.3]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.0.3/charts/dvpe-deployment-gloo
[3.0.4]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.0.4/charts/dvpe-deployment-gloo
[3.0.5]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.0.5/charts/dvpe-deployment-gloo
[3.0.6]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.0.6/charts/dvpe-deployment-gloo
[3.1.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.1.0/charts/dvpe-deployment-gloo
[3.1.1]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.1.1/charts/dvpe-deployment-gloo
[3.2.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.2.0/charts/dvpe-deployment-gloo
[3.2.1]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.2.1/charts/dvpe-deployment-gloo
[3.2.2]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.2.2/charts/dvpe-deployment-gloo
[3.2.3]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.2.3/charts/dvpe-deployment-gloo
[3.2.4]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-3.2.4/charts/dvpe-deployment-gloo
[4.0.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-4.0.0/charts/dvpe-deployment-gloo
[4.1.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-4.1.0/charts/dvpe-deployment-gloo
[4.2.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-4.2.0/charts/dvpe-deployment-gloo
[4.3.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-4.3.0/charts/dvpe-deployment-gloo
[4.4.0]: https://github.com/DVPE-cloud/dvpe-helm/tree/dvpe-deployment-gloo-4.4.0/charts/dvpe-deployment-gloo
