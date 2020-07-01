data "terraform_remote_state" "infrastructure" {
  backend = "s3"

  config {
    bucket  = "ecloud-terraform-state-${var.profile}"
    region  = "eu-west-2"
    profile = "${var.profile}"
    key     = "vpc/${var.region}/${var.profile}/terraform.tfstate"
  }
}
