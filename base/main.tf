provider "aws" {
  region  = "${var.region}"
  profile = "${var.profile}"
}

data "aws_caller_identity" "current" {}

locals {
  aws_account_id    = "${data.aws_caller_identity.current.account_id}"
  vpc_id            = "${data.terraform_remote_state.infrastructure.vpc_id}"
  lambda_suffix_01  = "lambda-ops-rabbitmq-shovel-01"
  s3_bucket_account = "${data.aws_caller_identity.current.account_id == "319701921293" ? "dev" : "core"}"
}

# ========================================= LAMBDA BUCKET CREATION & POLICY===================================================
#==========================================CREATE SECURITY GROUP ==========================================================
##This Security group will give access to the RabbitMQ Load Balancer SG for https calls from the python running on the lambda##

resource "aws_security_group" "access_to_rabbitmq_lb_sg" {
  name        = "lambda-rabbitmq-cluster-access"
  description = "This is used by the lambda to query the rabbitmq url"
  vpc_id      = "${data.terraform_remote_state.infrastructure.vpc_id}"


  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["${var.rabbitmq_lb_cidr}"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
#==========================================SNS TOPIC=======================================================================

resource "aws_sns_topic" "rabbitmq_shovel_report" {
  name 		= "awie-sns-${var.mode}-rabbitmq-shovel-run-report"
  display_name 	= "awie-sns-${var.mode}-rabbitmq-shovel-run-report"
}


resource "aws_lambda_permission" "allow_sns_to_trigger" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "awie-lm-${var.mode}-ops-rabbitmq-shovel-01"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.rabbitmq_shovel_report.arn}"
}

# ========================================= LAMBDA ========================================================================

# Best to leave the below commented out until the above has been terraformed first
module "Ops-Rabbitmq-Shovel" {
  source                         = "git@github.com:esure-dev/inf-ter-lambda-s3-deployment"
  function_name                  = "awie-lm-${var.mode}-ops-rabbitmq-shovel-01"
  function_version               = "${var.rabbitmq_shovel_function_version}"
  iam_role_name                  = "ec-iamr-${var.mode}-${local.lambda_suffix_01}"
  s3_bucket                      = "${var.s3_bucket_default}"
  s3_key                         = "${var.mode}/${var.rabbitmq_shovel_function_version}.zip"
  handler                        = "${var.profile}_lambda_function.rabbitmq_dynamic_shovel"
  runtime                        = "${var.runtime}"
  memory_size                    = "${var.memory_size}"
  timeout                        = "${var.timeout}"
  reserved_concurrent_executions = "${var.reserved_concurrent_executions}"
  publish                        = "${var.publish}"
  lambda_variables = {
    "ENV"                          	 = "${var.profile}"
    "MODE"                         	 = "${var.mode}"
    "LOG_LEVEL"                     	 = "DEBUG"
    "ROOT_LOG_LEVEL"               	 = "WARN"
    "RABBITMQ_USERNAME"            	 = "admin"
    "MESSAGES_THRESHOLD_CLAIMS"		 = "5"
    "MESSAGES_THRESHOLD_CUSTOMER"	 = "5"
    "MESSAGES_THRESHOLD_EVENTS_CAPTURE"	 = "5"
    "MESSAGES_THRESHOLD_HOME"		 = "5"
    "MESSAGES_THRESHOLD_MOTOR"		 = "5"
    "VHOSTS_ENDPOINT"               = "https://ops-rabbitmq-${var.profile}.escloud.co.uk/api/vhosts/"
    "QUEUES_ENDPOINT"               = "https://ops-rabbitmq-${var.profile}.escloud.co.uk/api/queues/"
    "SHOVEL_ENDPOINT"               = "https://ops-rabbitmq-${var.profile}.escloud.co.uk/api/parameters/shovel/"
    "VHOST_CLAIMS"		    = "claims"
    "VHOST_CUSTOMER"		    = "customer"
    "VHOST_EVENTS_CAPTURE"          = "events-capture"
    "VHOST_HOME"		    = "home"
    "VHOST_MOTOR"                   = "motor"
    "PREFETCH_COUNT"		    = "1000"
    "SNS_TOPIC_ARN"		    = "${aws_sns_topic.rabbitmq_shovel_report.arn}"
  }

  subnet_ids         = ["${split(",", data.terraform_remote_state.infrastructure.ops-rabbitmq-shovel-lambda_subnets)}"]
  security_group_ids = [
	"${data.terraform_remote_state.infrastructure.default_security_group_id}",
	"${aws_security_group.access_to_rabbitmq_lb_sg.id}"
	]

  role_policy_attachment     = true
  role_policy_attachment_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

#Attach the Amazon SNS Full Access Role to allow sending of emails##

resource "aws_iam_role_policy_attachment" "AmazonSNSFullAccess" {
  role       = "ec-iamr-${var.mode}-${local.lambda_suffix_01}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}


#===================================Cloudwatch Trigger==================================================================
resource "aws_cloudwatch_event_rule" "cloudwatch_invoke_rabbitmq_shovel" {
  name        = "awie-cw-${var.mode}-int-${var.profile}-ops-rabbitmq-shovel-01"
  description = "Trigger for the ops rabbitmq shovel lambda"

  schedule_expression = "${var.schedule_expression}"
}

resource "aws_cloudwatch_event_target" "cloudwatch_invoke_rabbitmq_shovel" {
  rule = "${aws_cloudwatch_event_rule.cloudwatch_invoke_rabbitmq_shovel.id}"
  arn  = "${module.Ops-Rabbitmq-Shovel.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_trigger" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "awie-lm-${var.mode}-ops-rabbitmq-shovel-01"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.cloudwatch_invoke_rabbitmq_shovel.arn}"
}
