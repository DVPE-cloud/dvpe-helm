# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

