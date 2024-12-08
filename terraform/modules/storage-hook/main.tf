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
  
  source = {
    bucket = "bucket"
  }
  
  trigger = {
    upload = "upload"
  }
}

module "base" {
  source  = "../base"
}

# bucket and objects that will trigger
variable "source" {
  type = object({
    bucket = string
  }) 
}

variable "trigger" {
  type    = object({
    event   = string
    filter  = string
  })
  default = {
    event   = local.trigger.upload
    filter  = "*" 
  }
}

variable "service" {
  type    = object({
    name      = string
    filepath  = string
    project_root = string
    entrypoint = string
  })
}

variable "sink" {
  type = string
  default = local.sink.void
}

locals {
  sink      = local.sink[var.sink]
  source    = local.source[var.source]
  trigger   = local.trigger[var.trigger]
  namespace = local.trigger[var.trigger]
}
