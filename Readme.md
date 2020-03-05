# Serverless Deployment on Cloud Run using Terraform

Blog post: [Serverless Deployment on Cloud Run using Terraform](https://medium.com/google-cloud/deploying-docker-images-to-cloud-run-using-terraform-ee8ae4ecb72e)

```sh
$ docker build -t gcr.io/terraform-cr/webapp flask docker
$ docker push gcr.io/terraform-cr/webapp
```

Deploy image to Cloud Run

```sh
$ terraform init
$ terraform plan
$ terraform apply
```

To later delete it

```sh
$ terraform destroy
```