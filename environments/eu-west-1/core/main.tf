provider "aws" {
  region  = "eu-west-1"
  profile = "core"
}

##======================== LAMBDA BUCKET =============================================

resource "aws_s3_bucket" "lambda-ops-rabbitmq-shovel-repository" {
  bucket = "awie-s3-ec-core-int-lambda-ops-rabbitmq-shovel-repository-01"
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

resource "aws_s3_bucket_policy" "lambda-ops-rabbitmq-shovel-repository" {
  bucket = "${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.id}"
  policy = "${data.aws_iam_policy_document.rabbitmq-shovel.json}"
}

data "aws_iam_policy_document" "rabbitmq-shovel" {
  statement = [{
    sid     = "AllowCoreUsers"
    actions = ["s3:*"]
    effect  = "Allow"

    resources = ["${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.arn}/*",
      "${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.arn}",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::319701921293:root"]
    }
  }]

  statement = [{
    sid     = "AllowDevUsers"
    actions = ["s3:Get*", "s3:List*", "s3:PutObject"]
    effect  = "Allow"

    resources = ["${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.arn}/*",
      "${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.arn}",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::050690872663:root"]
    }
  }]

  statement = [{
    sid     = "CrossAccountAccess"
    actions = ["s3:Get*", "s3:List*"]
    effect  = "Allow"

    resources = ["${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.arn}/*",
      "${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.arn}",
    ]

    principals {
      type = "AWS"

      identifiers = ["arn:aws:iam::706665555773:root",
        "arn:aws:iam::375857942905:root",
        "arn:aws:iam::340864205732:root",
      ]
    }
  }]
}

#============================CREATE THE S3 OBJECT OBJECT===========================

resource "aws_s3_bucket_object" "lambda-environment-folder_test" {
  bucket = "${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.id}"
  acl    = "private"
  key    = "test/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "lambda-environment-folder_prep" {
  bucket = "${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.id}"
  acl    = "private"
  key    = "prep/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "lambda-environment-folder_prod" {
  bucket = "${aws_s3_bucket.lambda-ops-rabbitmq-shovel-repository.id}"
  acl    = "private"
  key    = "prod/"
  source = "/dev/null"
}
