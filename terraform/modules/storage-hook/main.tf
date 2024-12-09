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

resource "aws_s3_bucket" "storage_hook_bucket" {
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
  policy = data.aws_iam_policy_document.storage_hook_iam_policy_document.json
}

data "aws_iam_policy_document" "storage_hook_iam_assume_role" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "storage_hook_iam_role" {
  name               = local.iam.role.name 
  assume_role_policy = data.aws_iam_policy_document.storage_hook_iam_assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "${var.service.entrypoint.filepath}"
  output_path = "${var.service.name}.zip"
}

resource "aws_lambda_function" "storage_hook_lambda" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename          = "${var.service.name}.zip"
  function_name     = var.service.name
  handler           = var.service.entrypoint.function 
  role              = aws_iam_role.storage_hook_iam_role.arn
  runtime           = local.lambda.language 
  source_code_hash  = data.archive_file.lambda.output_base64sha256
}

resource "aws_lambda_permission" "allow_storage_hook" {
  statement_id  = "AllowExecutionFromS3Bucket"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.storage_hook_lambda.arn
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.storage_hook_bucket.arn
}

resource "aws_s3_bucket_notification" "storage_hook_notification" {
  bucket = aws_s3_bucket.storage_hook_bucket.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.storage_hook_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [aws_lambda_permission.allow_storage_hook]
}

data "aws_iam_policy_document" "lambda_logging" {
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

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.storage_hook_iam_role.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}
