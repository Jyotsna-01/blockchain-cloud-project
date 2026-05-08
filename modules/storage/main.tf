# ─── RANDOM SUFFIX ─────────────────────────────────────────────────────────────
# S3 bucket names are GLOBALLY unique across all AWS accounts in the world.
# "blockchain-ai-app-bucket" might already be taken by someone else.
# So we add a random 6-character suffix to guarantee uniqueness.
resource "random_string" "bucket_suffix" {
  length  = 6
  special = false
  upper   = false
}

# ─── APP BUCKET ────────────────────────────────────────────────────────────────
# Stores Django static files, media uploads, and blockchain transaction records.
resource "aws_s3_bucket" "app" {
  bucket = "${var.project_name}-app-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-app-bucket"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "Application files and media uploads"
  }
}

# ─── BLOCK ALL PUBLIC ACCESS ON APP BUCKET ─────────────────────────────────────
# Medical data must NEVER be publicly accessible.
# This is a hard block — even if someone accidentally adds a public policy,
# this overrides it and keeps everything private.
resource "aws_s3_bucket_public_access_block" "app" {
  bucket = aws_s3_bucket.app.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── ENABLE VERSIONING ON APP BUCKET ───────────────────────────────────────────
# Versioning keeps a history of every file version.
# If someone accidentally overwrites a patient record — you can restore it.
# Critical for a medical data application.
resource "aws_s3_bucket_versioning" "app" {
  bucket = aws_s3_bucket.app.id

  versioning_configuration {
    status = "Enabled"
  }
}

# ─── ENCRYPT APP BUCKET ────────────────────────────────────────────────────────
# AES-256 server-side encryption — every object stored is encrypted at rest.
# Matches the storage_encrypted = true we set on RDS.
# Consistent encryption story across your entire architecture.
resource "aws_s3_bucket_server_side_encryption_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ─── LIFECYCLE RULE ON APP BUCKET ──────────────────────────────────────────────
# Automatically moves old file versions to cheaper storage after 30 days,
# and deletes them after 90 days. Saves cost without manual management.
resource "aws_s3_bucket_lifecycle_configuration" "app" {
  bucket = aws_s3_bucket.app.id

  rule {
    id     = "archive-old-versions"
    status = "Enabled"

    filter {}    # Empty filter = apply rule to ALL objects in the bucket

    noncurrent_version_transition {
      noncurrent_days = 30
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}

# ─── LOGS BUCKET ───────────────────────────────────────────────────────────────
# Every HTTP request that hits your ALB gets logged here.
# Useful for debugging, security audits, and usage analytics.
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project_name}-logs-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "${var.project_name}-logs-bucket"
    Environment = var.environment
    Project     = var.project_name
    Purpose     = "ALB access logs and application logs"
  }
}

# ─── BLOCK ALL PUBLIC ACCESS ON LOGS BUCKET ────────────────────────────────────
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ─── LIFECYCLE RULE ON LOGS BUCKET ─────────────────────────────────────────────
# Logs become less useful over time. Auto-delete after 90 days to save cost.
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    id     = "expire-old-logs"
    status = "Enabled"

    filter {}    # Empty filter = apply rule to ALL objects in the bucket

    expiration {
      days = 90
    }
  }
}