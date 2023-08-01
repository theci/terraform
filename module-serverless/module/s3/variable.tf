variable "zone_id" {
  type = string
  default = "Z10449893AKP9L3IDXBVR"
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
  default = "451456566564"
}