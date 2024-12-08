terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "base" {
  source  = "../base"
}

provider "aws" {
  region = module.base.var.region
}

resource "aws_s3_bucket" "hook_storage_bucket" {
  bucket  = local.bucket.name 
  tags    = local.bucket.tags
}

data "aws_iam_policy_document" "storage_hook_iam_policy_document" {
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

resource "aws_iam_policy" "storage_hook_iam_policy" {
  name   = local.iam.policy.name 
  path   = "/"
  policy = data.storage_hook_iam_policy_document.json
}

resource "aws_iam_role" "iam_for_lambda" {
  name               = local.iam.role.name 
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "storage_hook_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename          = "${var.service.name}.zip"
  function_name     = var.service.name
  handler           = "index.test"
  role              = aws_iam_role.iam_for_lambda.arn
  runtime           = local.lambda.language 
  source_code_hash  = data.archive_file.lambda.output_base64sha256
}

resource "aws_lambda_function" "storage_hook" {
  function_name = var.lambda.name 
  logging_config {
    log_format = "Text"
  }
  depends_on = [
    aws_iam_role_policy_attachment.lambda_logs,
  ]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/lambda/${var.lambda_function_name}"
  retention_in_days = 1
}
