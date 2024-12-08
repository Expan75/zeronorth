# enums
locals {
  environment = {
    personal    = "personal"      # local development 
    development = "development"   # latest green build
    production  = "production"    # latest release
  } 
  
  email = {
    billing = "infra@zero-north.com"
    contact = "infra@zero-north.com"
    owner   = "infra@zero-north.com"
  }

  region = {
    eu_north_1 = "eu-north-1"
  }

  default = {
    region      = local.region.eu_north_1 
    environment = local.environment.personal 
  }
}

variable "region" {
  type    = string
  default = "eu-north-1" 
}

variable "environment" {
  type    = string
  default = "personal" 
}

variable "owner" {
  type    = string
}

# output as we need to export to other modules
output "config" {
  value = {
    environment = local.environment[var.environment] 
    owner       = var.owner 
    region      = local.region[var.region]
  }
}
