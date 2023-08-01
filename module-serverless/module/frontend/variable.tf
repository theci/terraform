variable "zone_id" {
  type = string
  default = "Z01335121DQOOIZ9KEEJS"
}

variable "route53_record" {
  type = string
  default = "event.toydream.shop"
}


variable "cloudfront_alias" {
  type = string
  default = "event.toydream.shop"
}

variable "aws_iam_policy_document_identifier" {
  type = string
  default = "578310434439"
}

variable "acm_domain_name" {
  type = string
  default = "*.toydream.shop"
}
