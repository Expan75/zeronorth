terraform {
  required_version = "~> 1.9.8"

  backend "s3" {
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints = {
      s3 = "https://437871a8759ccae530c08bbd3dfd265f.eu.r2.cloudflarestorage.com"
    }
  }
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}

# consts
locals {
  service = {
    entrypoint = {
      filepath      = "../../challenge/main.py"
      function      = "on_upload" 
    }
    language        = "python"
    name            = "challenge"
  }
  trigger = {
    bucket = "jsonbucket" 
    filter = "*.json" 
    event  = "upload"
  }
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
  owner             = "erik.hakansson"
  source            = "../../../terraform/modules/storage-hook"
  service           = local.service
  trigger           = local.trigger
}
