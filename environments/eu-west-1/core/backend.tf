terraform {
  backend "s3" {
    region  = "eu-west-2"
    profile = "core"
    bucket  = "ecloud-terraform-state-coreinfra"
    key     = "s3/coreinfra/awie-s3-ec-core-int-lambda-ops-rabbitmq-shovel-repository-01/terraform.tfstate"
  }
}
