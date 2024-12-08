terraform {
  backend "s3" {} # congiured via backend.conf file
}

module "base" {
  source  = "../base"
}

# consts
locals {
  service   = "challenge"
  location  = "Copenhagen, Denmark"
  buckets   = []
}

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

module "challenge" {
  source            = "../../blocks/s3-lambda-hook"
  environment       = local.env
  service           = local.service
  tags              = local.default.tags
}
