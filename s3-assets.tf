resource "aws_s3_bucket" "assets" {
  bucket = module.labels.id
  acl    = "private"
  tags   = module.labels.tags

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


data "aws_iam_policy_document" "cloudfront_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.assets.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.origin_access_identity_s3.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudfront_access" {
  bucket = aws_s3_bucket.assets.id
  policy = data.aws_iam_policy_document.cloudfront_policy.json
}
