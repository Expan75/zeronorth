
variable "owner" {
  type = string
}

variable "environment" {
  type = string
  default = "eu-north-1"
}

variable "region" {
  type = string
  default = "eu-north-1"
}

variable "trigger" {
  type    = object({
    event   = string
    bucket  = string
    filter  = string
  })
}

variable "service" {
  type    = object({
    entrypoint    = string
    filepath      = string
    language      = string
    name          = string
    project_root  = string
  })
}
