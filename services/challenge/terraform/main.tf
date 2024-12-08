terraform {
  backend "s3" {} # congiured via backend.conf file
}

# consts
locals {
  service   = "challenge"
  owner     = "infra@example.com"
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

module "challenge" {
  source            = "../../../terraform/modules/storage-hook"
  service           = local.service
  trigger = {
    bucket = local.service
    filter = "*.json" 
    event  = "upload"
  }
}
