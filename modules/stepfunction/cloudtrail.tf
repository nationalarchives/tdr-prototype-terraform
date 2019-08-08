resource "aws_cloudtrail" "s3-step-function" {
  name                          = "s3-step-function-${var.environment}"
  s3_bucket_name                = aws_s3_bucket.step-function-cloudtrail.bucket
  depends_on = [aws_s3_bucket_policy.cloud-trail-s3-bucket-policy]
  event_selector {
    data_resource {
      type = "AWS::S3::Object"
      values = ["${aws_s3_bucket.upload-files.arn}/"]
    }
  }

  tags = merge(
    var.common_tags,
    map(
    "Name", "s3-step-function-cloudtrail-${var.environment}",
    )
  )
}