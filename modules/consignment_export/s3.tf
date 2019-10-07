resource "aws_s3_bucket" "consignment_export" {
  bucket = "tdr-consignment-export-${var.environment}"
  acl    = "private"

  tags = merge(
    var.common_tags,
    map(
      "Name", "tdr-consignment-export-${var.environment}",
    )
  )
}

resource "aws_s3_bucket_public_access_block" "consignment_export" {
  bucket = aws_s3_bucket.consignment_export.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
