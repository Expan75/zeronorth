terraform {
  backend "s3" {} # congiured via backend.conf file
}


# consts
locals {
  service   = "challenge"
  location  = "Copenhagen, Denmark"
  buckets   = []
}

/* If there's time
module "secrets" {
  source            = "../../blocks/secrets"
}

module "github" {
  source            = "../../blocks/github"
  repository = {
    name = "zeronorth"
    url  = "https://github.com/expan75/zeronorth"
  }
}
*/

module "base" {
  source  = "../base"
}

module "challenge" {
  source            = "../../../terraform/modules/storage-hook"
  environment       = module.base.env
  service           = var.service
  sink = "void"
  trigger = {
    bucket = local.service
    filter = "*.json" 
    event  = "upload"
  }
}
