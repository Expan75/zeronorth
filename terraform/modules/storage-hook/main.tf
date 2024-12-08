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
  policy = data.aws_iam_policy_document.storage_hook_iam_policy_document.json
}

resource "aws_iam_role" "storage_hook_iam_role" {
  name               = local.iam.role.name 
  assume_role_policy = data.aws_iam_policy_document.storage_hook_iam_policy_document.json
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
