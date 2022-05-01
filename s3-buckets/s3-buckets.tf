// S3 bucket for store logs
resource "aws_s3_bucket" "log_bucket" {
  bucket = "file-manager-log-bucket"

  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "Domain" = "jubbiepizza"
    "App"    = "file-manager"
  }
}

resource "aws_s3_bucket_acl" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket" {
  bucket = aws_s3_bucket.log_bucket.bucket
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

// S3 bucket with static website content
resource "aws_s3_bucket" "website_bucket" {
  bucket = "file-manager-website-bucket"


  lifecycle {
    prevent_destroy = true
  }

  tags = {
    "Domain" = "jubbiepizza"
    "App"    = "file-manager"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = false
  }
}

resource "aws_s3_bucket_logging" "website_bucket" {
  bucket        = aws_s3_bucket.website_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}
