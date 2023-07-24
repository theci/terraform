provider "aws" {
  alias = "virginia"
  region = "us-east-1"
  default_tags {
    tags = {
      project = "serverless-demo",
      type    = "web",
      iac     = "terraform"
    }
  }
}

#

resource "aws_s3_bucket" "website_bucket" {
  bucket = "final_project-event-page"
}

#resource "aws_s3_object" "website_bucket" {
#  bucket       = aws_s3_bucket.website_bucket.id
#  key          = "index.html"
#  source       = "index.html"
#  content_type = "text/html"
#}



### 버킷 정책
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "example" {
  depends_on = [
    aws_s3_bucket_ownership_controls.example,
    aws_s3_bucket_public_access_block.website_bucket,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "private"
}

resource "aws_s3_bucket_policy" "allow_access_from_another_account" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_another_account.json
}

data "aws_iam_policy_document" "allow_access_from_another_account" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["451456566564"]
    }

    actions = [
      "s3:GetObject",
      "s3:ListBucket",
    ]

    resources = [
      aws_s3_bucket.website_bucket.arn,
      "${aws_s3_bucket.website_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_website_configuration" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  index_document {
    suffix = "index.html"
  }
}

