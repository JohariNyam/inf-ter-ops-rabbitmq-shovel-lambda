terraform {
  backend "s3" {
    region  = "eu-west-2"
    profile = "prod"
    bucket  = "ecloud-terraform-state-prod"
    key     = "lambda/eu-west-1/environment/prod/ops-rabbitmq-shovel/terraform.tfstate"
  }
}
