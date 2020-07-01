terraform {
  backend "s3" {
    region  = "eu-west-2"
    profile = "test"
    bucket  = "ecloud-terraform-state-test"
    key     = "lambda/eu-west-1/environment/test/ops-rabbitmq-shovel/terraform.tfstate"
  }
}
