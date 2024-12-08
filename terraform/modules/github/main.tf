terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.4"
    }
  }
}

locals {
  default = {
    branch = "main"
  }
}

# note that repository creation and settings are not managed by this module (or any other). 
variable "repository" {
  type = object({
    environment       = string 
    owner             = string 
    name              = string 
    url               = string
  })
}

variable "workflow_secrets" {
  sensitive = true
  type      = set(string)
}

provider "github" {
  owner = var.repository.owner
}

resource "github_actions_secret" "action_secrets" {
  for_each         = var.workflow_secrets
  repository       = var.repository.name 
  secret_name      = each.value
}
