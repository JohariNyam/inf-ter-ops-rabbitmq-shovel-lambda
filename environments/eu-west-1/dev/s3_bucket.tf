
#======================================================LAMBDA BUCKET CREATION & POLICY===================================================
# The below must be terraformed first before the lambda, otherwise the lambda will fail because it can't see the bucket and function version ####

resource "aws_s3_bucket_policy" "lambda-ops-rabbitmq-dev-policy" {
  bucket = "awie-s3-ec-int-lambda-ops-rabbitmq-shovel-repository-01"
  policy = "${file("lambda-policy.json")}"

}

resource "aws_s3_bucket" "lambda-ops-rabbitmq-shovel-dev-s3" {
  bucket = "awie-s3-ec-int-lambda-ops-rabbitmq-shovel-repository-01"
  acl    = "private"


  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}
resource "aws_s3_bucket_object" "lambda-environment-dev-folder" {
  bucket = "${aws_s3_bucket.lambda-ops-rabbitmq-shovel-dev-s3.id}"
  acl    = "private"
  key    = "${var.mode}/"
  source = "/dev/null"

}
