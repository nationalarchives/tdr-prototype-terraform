resource "aws_s3_bucket" "step-function-cloudtrail" {
  bucket = "step-function-cloudtrail-${var.environment}"
  acl    = "private"

  tags = merge(
    var.common_tags,
    map(
    "Name", "step-function-${var.environment}",
    )
  )
}

// Upload files bucket. This won't stay here
resource "aws_s3_bucket" "upload-files" {
  bucket = "tdr-upload-files-${var.environment}"
  acl    = "private"

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
  }

  tags = merge(
    var.common_tags,
    map(
      "Name", "tdr-upload-files-${var.environment}",
    )
  )
}

resource "aws_s3_bucket_policy" "cloud-trail-s3-bucket-policy" {
  bucket = aws_s3_bucket.step-function-cloudtrail.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [{
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": { "Service": "cloudtrail.amazonaws.com" },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.step-function-cloudtrail.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": { "Service": "cloudtrail.amazonaws.com" },
            "Action": "s3:PutObject",
            "Resource": ["${aws_s3_bucket.step-function-cloudtrail.arn}/AWSLogs/${var.account_id}/*"],
            "Condition": { "StringEquals": { "s3:x-amz-acl": "bucket-owner-full-control" } }
        }]

}
POLICY
}