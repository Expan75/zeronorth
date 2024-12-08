

# should have the access rights to atleast manage:
#   - buckets 
#   - lambdas 
#   - IAM policies, 
#   - stackmonitoring.
variable "aws_access_key_id" {
  type      = string
  sensitive = true 
}
variable "aws_secret_access_key" {
  type      = string
  sensitive = true 
}

variable "environment" {
  type      = string
  default   = "personal" 
}

