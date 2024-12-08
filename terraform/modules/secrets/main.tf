terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

module "base" {
  source = "../base"
}

variable "service" {
  type = string
}

variable "secrets" {
  type        = set(string)
  sensitive   = true 
}

locals {
  namespace = "${module.base.region}-${module.base.environment}-${var.service}"
}

provider "aws" {
  region = module.base.region
}
