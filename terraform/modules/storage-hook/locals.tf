locals {
  event = {
    upload = "upload"
  }
  language = {
    python = "python3.12"
  }

  namespace = "${module.base.config.region}-${module.base.config.environment}-${var.service.name}"
  bucket = {
    name = "${local.namespace}-${local.trigger.bucket}" 
    tags = {
      Region      = module.base.config.region 
      Environment = module.base.config.environment
      Region      = module.base.config.region
      Service     = var.service.name
    }
  }
  
  iam = {
    policy = {
      name = "${local.namespace}-iam-policy"
    }
    role = {
      name    = "${local.namespace}-iam-policy" 
    }
  }
  
  lambda = {
    name      = "${local.namespace}-lambda" 
    region    = module.base.config.region 
    language  = local.language[var.service.language]
  }
  
  trigger   = {
    bucket    = var.trigger.bucket
    event     = local.event[var.trigger.event]
    filter    = var.trigger.filter
  }
}
