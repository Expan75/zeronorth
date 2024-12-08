terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = module.base.var.region
}

locals {
  sink = {
    void   = "void"
  }
 
  event = {
    upload = "upload"
  }

  language = {
    python = "python3.12"
  }
}

module "base" {
  source  = "../base"
}

variable "trigger" {
  type    = object({
    event   = string
    bucket  = string
    filter  = string
  })
  default = {
    event   = local.trigger.upload
    bucket  = "myservice" 
    filter  = "*" 
  }
}

variable "service" {
  type    = object({
    name          = string
    entrypoint    = string
    filepath      = string
    language      = string
    project_root  = string
  })
}

variable "sink" {
  type = string
  default = local.sink.void
}

locals {
  lambda = {
    name      = "${module.base.region}-${module.base.env}-${service.name}" 
    region    = module.base.region 
    language  = local.language[var.service.language]
  }
  tags = {
    Region      = module.base.region 
    Environment = module.base.environment
    Region      = module.base.region
    Service     = var.service
  }
  trigger   = {
    bucket    = local.trigger.bucket
    event     = local.event[var.trigger.event]
  }
  sink = local.sink[var.sink]

}

resource "aws_s3_bucket" "hook_storage_bucket" {
  bucket  = "${module.base.region}-${module.base.environment}-${service.name}-${trigger.bucket}"  
  tags    = local.tags
}


data "aws_iam_policy_document" "storage_hook_iam_policy_document" {
  statement {
    sid = "1"
    actions = [
      "s3:ListAllMyBuckets",
      "s3:GetBucketLocation",
    ]
    resources = [
      "arn:aws:s3:::*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}",
    ]
    condition {
      test     = "StringLike"
      variable = "s3:prefix"
      values = [
        "",
        "home/",
        "home/&{aws:username}/",
      ]
    }
  }

  statement {
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}",
      "arn:aws:s3:::${var.s3_bucket_name}/home/&{aws:username}/*",
    ]
  }
}

resource "aws_iam_policy" "example" {
  name   = "example_policy"
  path   = "/"
  policy = data.aws_iam_policy_document.example.json
}


resource "aws_iam_role" "iam_for_lambda" {
  name               = "iam_for_lambda"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "archive_file" "lambda" {
  type        = "zip"
  source_file = "lambda.js"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "storage_hook" {
  # If the file is not in the current working directory you will need to include a
  # path.module in the filename.
  filename          = "lambda_function_payload.zip"
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
