output "cloudfront_url" {
  value = aws_cloudfront_distribution.cdn_static_site.domain_name
}
