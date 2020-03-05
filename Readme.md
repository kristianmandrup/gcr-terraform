# Serverless Deployment on Cloud Run using Terraform

## Pre-requisites

Terraform (0.12) installation

[Installing Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

The template uses [Terraform google_cloud_run_service](https://www.terraform.io/docs/providers/google/r/cloud_run_service.html)

Based on Blog post: [Serverless Deployment on Cloud Run using Terraform](https://medium.com/google-cloud/deploying-docker-images-to-cloud-run-using-terraform-ee8ae4ecb72e)

## GCR infrastructure

The infrastructure consists of

- GCR service with auto-scaling to one node maximum
- storage bucket
- no authentication

TODO: add policy for service to write to storage bucket

### Create GCR infrastructure

```sh
$ terraform init
# ...
$ terraform plan
# ...
$ terraform apply
# ...
```

Variables exposed:

- `project` Goggle Cloud project name (default: `microfrontend-app`)
- `service` name of the service (default: `importmap-deployer`)
- `location` region (default: `us-east-1`)
- `bucket` Storage bucket (default: `importmap`)

To set a specific location (region)

```sh
$ terraform apply -var region=us-west-2
# ...
```

Referencing a `tfvars` file with variables

```sh
$ terraform apply -var-file="dev.tfvars"
# ...
```

Sample `dev.tfvars` file:

```tfvars
project=my-project
location=us-west-1
bucket=my-bucket
```

[Using Environment variables](https://www.terraform.io/docs/configuration/variables.html#environment-variables)

Create environment variables with prefix `TF_VAR_` followed by the name of a declared variable.

```sh
$ export TF_VAR_project=my-cool-project
$ terraform plan
# ...
```

To later delete the service

```sh
$ terraform destroy
# ...
```

## Deploy importmap-deployer image to GCR

Define environment variables

```sh
$ EXPORT $GCR_PRJ_NAME=microfrontend-app
$ EXPORT $GCR_CLUSTER_NAME=importmap-deployer
# ...
```

Build image and deploy to GCR

```sh
$ docker build -t gcr.io/$GCR_NAME/$GCR_CLUSTER_NAME importmap-deployer
# ...
$ docker push gcr.io/$GCR_NAME/$GCR_CLUSTER_NAME
# ...
```
