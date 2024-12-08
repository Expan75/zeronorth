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

variable "service" {
  type    = string
}

provider "aws" {
  region = module.base.var.region
}
