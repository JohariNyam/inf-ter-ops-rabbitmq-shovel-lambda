terraform {
  backend "s3" {
    region  = "eu-west-2"
    profile = "dev"
    bucket  = "ecloud-terraform-state-dev"
    key     = "lambda/eu-west-1/environment/dev/ops-rabbitmq-shovel/terraform.tfstate"
  }
}
