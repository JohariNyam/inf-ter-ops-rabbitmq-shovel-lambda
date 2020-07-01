terraform {
  backend "s3" {
    region  = "eu-west-2"
    profile = "prep"
    bucket  = "ecloud-terraform-state-prep"
    key     = "lambda/eu-west-1/environment/prep/ops-rabbitmq-shovel/terraform.tfstate"
  }
}
