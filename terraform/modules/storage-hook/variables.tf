
variable "trigger" {
  type    = object({
    event   = string
    bucket  = string
    filter  = string
  })
}

variable "service" {
  type    = object({
    name          = string
    entrypoint    = string
    filepath      = string
    language      = string
    project_root  = string
  })
}
