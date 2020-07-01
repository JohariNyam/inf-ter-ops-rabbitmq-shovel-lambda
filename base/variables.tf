
variable "profile" {}
variable "mode" {}
#variable "environment" {}

variable "region" {
  type    = "string"
  default = "eu-west-1"
}

variable "runtime" {
  default = "python3.7"
}

variable "memory_size" {
  default = "1024"
}

variable "timeout" {
  default = "600"
}

variable "reserved_concurrent_executions" {}

variable "publish" {
  default = false
}

variable "enabled" {
  type    = "string"
  default = "1"
}

variable "schedule_expression" {
  default = "rate(6 hours)"
}

variable "rabbitmq_lb_cidr" { type = "list" }

variable "rabbitmq_sns_subscribers" {}

variable "rabbitmq_shovel_function_version" {
  type        = "string"
  description = "version of download lambda to deploy"
}

variable "s3_bucket_default" {
  default = "awie-s3-ec-core-int-lambda-ops-rabbitmq-shovel-repository-01"
}

