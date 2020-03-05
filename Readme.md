# Importmap Deployer for MFE on Google Cloud Run using Terraform

See also [pulumi-importmap-deployer-ts](https://github.com/kristianmandrup/pulumi-importmap-deployer-ts) for a similar stack deployment using [Pulumi](https://www.pulumi.com)

## Pre-requisites

Terraform (0.12) installation

[Installing Terraform](https://learn.hashicorp.com/terraform/getting-started/install.html)

The template uses [Terraform google_cloud_run_service](https://www.terraform.io/docs/providers/google/r/cloud_run_service.html)

Based on Blog post: [Serverless Deployment on Cloud Run using Terraform](https://medium.com/google-cloud/deploying-docker-images-to-cloud-run-using-terraform-ee8ae4ecb72e)

## GCR infrastructure

The infrastructure consists of

- GCR service
- Storage bucket

### GCR service

- auto-scaling to one node maximum
- no authentication requirements by default

### Storage bucket

- write access for all users

### Access control

- [google_storage_bucket_access_control](https://www.terraform.io/docs/providers/google/r/storage_bucket_access_control.html)
- [google_cloud_run_service_iam_policy](https://www.terraform.io/docs/providers/google/r/cloud_run_service_iam.html)

Control access via [members](https://www.terraform.io/docs/providers/google/r/cloud_run_service_iam.html#member-members)

Watch [Secure Policy Management for the Cloud Services Platform](https://www.youtube.com/watch?v=3wsiL1zSFqQ) from Cloud Next '19

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

## Edit importmap configuration

Edit `importmap-deployer/conf.js` to match your project.

See [import-map-deployer: configuration file](https://github.com/single-spa/import-map-deployer#configuration-file) for documentation on how to configure it

`username` (optional): The username for HTTP auth when calling the `import-map-deployer`. If `username` and `password` are omitted, anyone can update the import map without authenticating. This username is not related to authenticating with S3/Digital Ocean/Other, but rather is the username your CI process will use in its HTTP request to the `import-map-deployer`.

`password` (optional): The password for HTTP auth when calling the `import-map-deployer`. If `username` and `password` are omitted, anyone can update the import map without authenticating. This password is not related to authenticating with S3/Digital Ocean/Other, but rather is the password your CI process will use in its HTTP request to the `import-map-deployer`.

`manifestFormat` (required): A string that is either `importmap` or `sofe`, which indicates whether the `import-map-deployer` is interacting with an import map or a sofe manifest.

`locations` (required): An object specifying one or more "locations" (or "environments") for which you want the `import-map-deployer` to control the import map. The special `default` location is what will be used when no query parameter ?env= is provided in calls to the import-map-deployer. 
If no `default` is provided, the `import-map-deployer` will create a local file called `import-map.json` that will be used as the import map. The keys in the locations object are the names of environments, and the values are strings that indicate how the `import-map-deployer` should interact with the import map for that environment. 

```js
module.exports = {
  username: process.env.HTTP_USERNAME,
  password: process.env.HTTP_PASSWORD,
  manifestFormat: 'importmap',
  locations: {
    reactMf: 'google://react.microfrontends.app/importmap.json',
    vueMf: 'google://vue.microfrontends.app/importmap.json',
    polyglotMf: 'google://polyglot.microfrontends.app/importmap.json',
    angularMf: 'google://angular.microfrontends.app/importmap.json'
  }
};
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
