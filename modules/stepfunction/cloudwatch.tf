resource "aws_cloudwatch_event_rule" "step-function-cloudwatch-rule" {
  name        = "step-function-cloudwatch-rule-${var.environment}"
  description = "Triggers step function on receipt of cloud trail trail"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.s3"
  ],
  "detail-type": [
    "AWS API Call via CloudTrail"
  ],
  "detail": {
    "eventSource": [
      "s3.amazonaws.com"
    ],
    "eventName": [
      "PutObject"
    ],
    "requestParameters": {
      "bucketName": [
        "${aws_s3_bucket.upload-files.bucket}"
      ]
    }
  }
}
PATTERN
  tags = merge(
  var.common_tags,
  map(
  "Name", "step-function-cloudwatch-rule-${var.environment}",
  )
  )
}


resource "aws_cloudwatch_event_target" "step-function-cloudwatch-rule-target" {
  rule = aws_cloudwatch_event_rule.step-function-cloudwatch-rule.name
  arn = aws_sfn_state_machine.sfn_state_machine.id
  role_arn = "arn:aws:iam::247222723249:role/service-role/AWS_Events_Invoke_Step_Functions_1315981831"
}