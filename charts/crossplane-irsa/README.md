# crossplane-irsa

![Version: 0.4.0](https://img.shields.io/badge/Version-0.4.0-informational?style=flat-square)

Helm chart for installing a custom crossplane xrd for creating AWS IRSA roles.

## Installation

Pre-Requirements:

- Installed [Crossplane](https://crossplane.io)
- Installed [Crossplane AWS Provider Package](https://github.com/crossplane/provider-aws)
- Installed and Configured [Crossplane Kubernetes Provider Package](https://github.com/crossplane-contrib/provider-kubernetes)
- Configured [AWS Role with IAM permissions to setup IAM Roles/Policies in the AWS account for Crossplane](https://crossplane.io/docs/v1.7/cloud-providers/aws/aws-provider.html)

Deploy the crossplane-irsa Chart by filling the the values.yaml.
Use helm or other helm based deployment tooling (like argocd) to deploy this Chart.

## Naming Conventions

This Crossplane component will generate an IAM Role, IAM Policy and a K8S Service Account. All of those resources will be connected to each other so that they apply to the rules
defined in [IAM Roles For Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html).

The following naming conventions need to be considered when creating a new `IamRoleForServiceAccountClaim`.

### AWS IAM Role

`k8s-<spec.roleFor.namespace>-sa-role`

### AWS IAM Policy

`<spec.roleFor.namespace>-irsa-policy`

### K8S Service Account

`<spec.roleFor.namespace>-sa`

## Example for IRSA within local AWS account

Fill the `values.yaml` with your settings und set the `xrd.type` to `local`.

### Deploy the helm chart:

```sh
helm install crossplane-irsa . -f values.yaml
```

### Create a local IRSA role

The sample below will result in the creation of the following components:
* A K8S Service Account with name `default-sa`.
* An AWS IAM Role with name `k8s-default-sa-role` and an including trust relationship pointing to the Service Account `default-sa`.
* An AWS IAM Policy with name `default-irsa-policy` containing the IAM Policy Document provided with the `policy` parameter.

Example IRSA:
```yaml
apiVersion: irsa.company.tld/v1alpha1
kind: IamRoleForServiceAccountClaim
metadata:
  name: irsa-sample
  namespace: default
spec:
  roleFor:
    namespace: default
  policy: |
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": [
            "s3:Get*",
            "s3:List*",
            "s3-object-lambda:Get*",
            "s3-object-lambda:List*"
          ],
          "Resource": "*"
        }
      ]
    }
  compositionRef:
    name: crossplane-irsa
```

### Deploy your service and use the newly generated Service Account from the IRSA role created before

Example Pod:
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myapp
  labels:
    name: myapp
spec:
  serviceAccountName: <namespace>-sa
  containers:
    :
```

## Example for IRSA with role assume to a different AWS account

Fill the `values.yaml` with your settings und set the `xrd.type` to `remote`.

### Deploy the helm chart:

```sh
helm install crossplane-irsa . -f values.yaml
```

### Setup remote AWS Account

Based on the [AWS Cross account IAM Roles for kubernetes service accounts](https://aws.amazon.com/blogs/containers/cross-account-iam-roles-for-kubernetes-service-accounts/)
the OIDC Provider connectivity between both AWS Accounts must be setup as additional step.

An example Cloudformation Template in `samples/oidc-provider-cloudformation.tpl.yaml` can be used to setup the OIDC Config.
The example template will create a basic policy to get access to S3 Buckets.
You should edit the `PolicyDocument` section from `LocalRole` resource before use (do not change the `AssumeRolePolicyDocument`) !

### Use the sample cloudformation template

1. Get the following EKS OIDC Provider informations from the `local`/`source` AWS Account (the EKS Cluster based AWS Account)

- OIDC Provider URL
- OIDC Provider Thumbprint

2. Create a cloudformation stack on the `remote`/`target` AWS Account

Open the AWS WebConsole from the remote AWS account.
Go to Cloudformation and select create Stack.
Upload the sample template and fill the required informations.

### Create a remote IRSA role

The sample below will result in the creation of the following components:
* A K8S Service Account with name `default-remote-sa`.
* An AWS IAM Role with name `k8s-default-sa-remote-role` and an including trust relationship pointing to the Service Account `default-sa`.
* An AWS IAM Policy with name `default-irsa-remote-policy` containing an IAM Policy Document which allows to perform an `sts:assumeRole` Action for the AWS IAM Role provided with the `remoteRoleArn` property.

Example IRSA:
```yaml
apiVersion: irsa.company.tld/v1alpha1
kind: RemoteIamRoleForServiceAccountClaim
metadata:
  name: irsa-sample
  namespace: default
spec:
  remoteRoleArn: arn:aws:iam::<AWS ACCOUNT ID>:role/<REMOTE TENANT ROLE NAME>

  deletionPolicy: Delete

  compositionRef:
    name: crossplane-irsa
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
  serviceAccountName: <namespace>-sa
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
| provider.awsConfigName | string | `nil` | The name of the AWS Crossplane Provider used to provision this component. |
| provider.k8sConfigName | string | `nil` | The name of the K8S Crossplane Provider used to provision this component. |
| xrd.apiGroup | string | `nil` | The name of the API Group this resource should be exposed to. |
| xrd.type | string | `nil` | Set the IAM Policy access mode (`local` or `remote`). Local means IRSA policy for same AWS account. Remote will create a assume role for remote account ARN |
| xrd.version | string | `"v1alpha1"` | The version of this component (MUST not be overridden from outside). |
