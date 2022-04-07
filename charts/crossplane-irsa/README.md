# crossplane-irsa

![Version: 0.0.1](https://img.shields.io/badge/Version-0.0.1-informational?style=flat-square)

Helm chart for installing a custom crossplane xrd for creating AWS IRSA roles.

## Installation

Pre-Requirements:

- Installed [Crossplane](https://crossplane.io)
- Installed [Crossplane AWS Provider Package](https://github.com/crossplane/provider-aws)
- Installed and Configured [Crossplane Kubernetes Provider Package](https://github.com/crossplane-contrib/provider-kubernetes)
- Configured [AWS Role with IAM permissions to setup IAM Roles/Policies in the AWS account for Crossplane](https://crossplane.io/docs/v1.7/cloud-providers/aws/aws-provider.html)

Deploy the crossplane-irsa Chart by filling the the values.yaml.
Use helm or other helm based deployment tooling (like argocd) to deploy this Chart.

## For IRSA within same account

Fill the `values.yaml` with your settings
Set the `xrd.type` to `local` in values.yaml

### Deploy the helm chart:

```sh
helm install crossplane-irsa . -f values.yaml
```

### Deploy your service and use the newly generated service account from the crossplane-irsa

Example Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  labels:
    name: myapp
spec:
  serviceAccountName: namespace-sa
  containers:
    :
```

## For IRSA with role assume to an other account

Fill the `values.yaml` with your settings
Set the `xrd.type` to `remote` in values.yaml

### Deploy the helm chart:

```sh
helm install crossplane-irsa . -f values.yaml
```

### Setup remote AWS Account

To allow the EKS Cluster

Based on the [AWS Cross account IAM Roles for kubernetes service accounts](https://aws.amazon.com/blogs/containers/cross-account-iam-roles-for-kubernetes-service-accounts/)
the OIDC Provider connectivity between both AWS Accounts must be setup as additional step.

An example Cloudformation Template in `samples/oidc-provider-cloudformation.tpl.yaml` can be used to setup the OIDC Config.

### Use the sample cloudformation template

Open the AWS WebConsole from the remote AWS account.

1. Get the following EKS OIDC Provider informations from the `local`/`source` AWS Account (the EKS Cluster based AWS Account)
- OIDC Provider URL
- OIDC Provider Thumbprint

2. Create a cloudformation stack on the `remote`/`target` AWS Account

Open the Cloudformation and select create Stack.
Upload the sample template and fill the required informations.

### Deploy your service and use the newly generated service account from the crossplane-irsa

Example Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  labels:
    name: myapp
spec:
  serviceAccountName: namespace-sa
  containers:
    :
```

## Configuration

The following table lists the configurable parameters of the chart and its default values.

## Values

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| aws.accountId | string | `nil` | ID of the AWS Account this component should be provisioned to. |
| aws.oidcProviderId | string | `nil` | ID of the EKS Identity Provider that grants access to IAM roles for speaking with the EKS cluster. |
| composition.name | string | `"crossplane-irsa"` | The name of the crossplane composition (MUST not be overridden from outside). |
| provider.awsConfigName | string | `nil` | The name of the AWS Crossplane Provider used to provision this component. |
| provider.k8sConfigName | string | `nil` | The name of the K8S Crossplane Provider used to provision this component. |
| xrd.apiGroup | string | `nil` | The name of the API Group this resource should be exposed to. |
| xrd.type | string | `nil` | Set the IAM Policy access mode (`local` or `remote`). Local means IRSA policy for same AWS account. Remote will create a assume role for remote account ARN |
| xrd.version | string | `"v1alpha1"` | The version of this component (MUST not be overridden from outside). |
