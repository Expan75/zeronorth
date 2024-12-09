terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "base" {
  source      = "../base"
  environment = var.environment
  owner       = var.owner
  region      = var.region
}

provider "aws" {
  region = module.base.config.region
}

resource "aws_s3_bucket" "this" {
  bucket  = local.bucket.name 
  tags    = local.bucket.tags
}


data "aws_iam_policy_document" "lambda_to_s3_policy" {
  statement {
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::${local.bucket.name}",
    ]
  }
  statement {
    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:Describe*",
      "s3-object-lambda:Get*",
      "s3-object-lambda:List*"
    ]
    resources = [
      "arn:aws:s3:::${local.bucket.name}/${local.trigger.filter}",
    ]
  }
}

resource "aws_iam_policy" "lambda_to_s3_policy" {
  name   = local.iam.policy.name 
  path   = "/"
  policy = data.aws_iam_policy_document.lambda_to_s3_policy.json
}

data "aws_iam_policy_document" "s3_to_lambda_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "this" {
  name               = local.iam.role.name 
  assume_role_policy = data.aws_iam_policy_document.s3_to_lambda_policy.json
}

data "archive_file" "this" {
  type        = "zip"
  source_file = "${var.service.entrypoint.filepath}"
  output_path = "${var.service.name}.zip"
}

resource "aws_lambda_function" "this" {
  filename          = "${var.service.name}.zip"
  function_name     = local.lambda.name 
  handler           = var.service.entrypoint.function 
  role              = aws_iam_role.this.arn
  runtime           = local.lambda.language 
  source_code_hash  = data.archive_file.this.output_base64sha256
}

resource "aws_lambda_permission" "this" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.this.arn
}

resource "aws_s3_bucket_notification" "this" {
  bucket = aws_s3_bucket.this.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.this.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.this]
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${local.lambda.name}"
  retention_in_days = 1 
}

data "aws_iam_policy_document" "logging" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.logging.json
}

resource "aws_iam_role_policy_attachment" "logging" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.logging.arn
}
