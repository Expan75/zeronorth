# enums
locals {
  environment = {
    development = "development"
    production  = "production"
  } 
  
  email = {
    billing = "infra@zero-north.com"
    contact = "infra@zero-north.com"
    owner   = "infra@zero-north.com"
  }

  region = {
    "eu-north-1"
  }

  default = {
    region      = "eu-north-1"
    environment = "development"
  }
}

variable "region" {
  type    = string
  default = local.default.region 
}

variable "environment" {
  type    = string
  default = local.default.environment 
}

variable "owner" {
  type    = string
}

# derived vars 
locals {
  globals = {
    environment = local.environment[var.environment] 
    owner       = var.owner 
    region      = local.region[var.region]
  }
}

output "base" {
  value = local.globals
}

