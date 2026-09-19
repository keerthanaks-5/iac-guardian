# ✅ INTENTIONALLY WELL-CONFIGURED — this is our "control" file.
# A good AI reviewer should give this file a clean bill of health
# (or only very minor/optional suggestions), proving it isn't just
# flagging everything by default.

resource "aws_s3_bucket" "app_logs" {
  bucket = "my-company-app-logs-prod"

  tags = {
    Environment = "production"
    Owner       = "platform-team"
    CostCenter  = "eng-infra"
  }
}

# Public access fully blocked
resource "aws_s3_bucket_public_access_block" "app_logs_access" {
  bucket = aws_s3_bucket.app_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls       = true
  restrict_public_buckets = true
}

# Encryption at rest enabled
resource "aws_s3_bucket_server_side_encryption_configuration" "app_logs_encryption" {
  bucket = aws_s3_bucket.app_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Versioning enabled to protect against accidental deletion
resource "aws_s3_bucket_versioning" "app_logs_versioning" {
  bucket = aws_s3_bucket.app_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rule to move old logs to cheaper storage automatically
resource "aws_s3_bucket_lifecycle_configuration" "app_logs_lifecycle" {
  bucket = aws_s3_bucket.app_logs.id

  rule {
    id     = "archive-old-logs"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }
}
