
variable "owner" {
  type = string
}

variable "environment" {
  type = string
  default = "personal"
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
    entrypoint    = object({
      filepath      = string    # if relative, depends on where the module is imported and called! 
      function      = string
    }) 
    language      = string
    name          = string
  })
}
