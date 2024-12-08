
module "base" {
  source  = "../base"
}

locals {
  sink = {
    void   = "void"
  }
  event = {
    upload = "upload"
  }
  language = {
    python = "python3.12"

  namespace = "${module.base.region}-${module.base.environment}-${service.name}"
  bucket = {
    name = "${local.namepsace}-${local.trigger.bucket}" 
    tags = {
      Region      = module.base.region 
      Environment = module.base.environment
      Region      = module.base.region
      Service     = var.service
    }
  }
  
  iam = {
    policy = {
      name = "${local.namespace}-iam-policy"
    }
    role = {
      name =    = "${local.namespace}-iam-policy" 
    }
  }
  
  lambda = {
    name      = "${local.namepsace}-lambda" 
    region    = module.base.region 
    language  = local.language[var.service.language]
  }
  
  trigger   = {
    bucket    = var.trigger.bucket
    event     = local.event[var.trigger.event]
    filter    = var.trigger.filter
  }
  
  sink = local.sink[var.sink]
}
