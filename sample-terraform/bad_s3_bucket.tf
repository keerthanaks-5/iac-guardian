# ⚠️ INTENTIONALLY MISCONFIGURED — for testing the AI reviewer
# This file simulates a common real-world mistake: a storage bucket
# left wide open to the public internet, like a filing cabinet
# left unlocked in a public lobby.

resource "aws_s3_bucket" "user_uploads" {
  bucket = "my-company-user-uploads-prod"
}

# Problem 1: Public access is explicitly allowed
resource "aws_s3_bucket_public_access_block" "user_uploads_access" {
  bucket = aws_s3_bucket.user_uploads.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls       = false
  restrict_public_buckets = false
}

# Problem 2: No encryption configured at rest
# (missing aws_s3_bucket_server_side_encryption_configuration entirely)

# Problem 3: No versioning — accidental deletes/overwrites are permanent
# (missing aws_s3_bucket_versioning entirely)

# Problem 4: Bucket policy allows anyone on the internet to read AND write
resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.user_uploads.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadWrite"
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject", "s3:PutObject"]
        Resource  = "${aws_s3_bucket.user_uploads.arn}/*"
      }
    ]
  })
}
