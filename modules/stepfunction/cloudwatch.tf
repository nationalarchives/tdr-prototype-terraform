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

data "aws_iam_policy_document" "invoke_step_function_assume_role" {
   version = "2012-10-17"
   statement {
     effect  = "Allow"
     actions = ["sts:AssumeRole"]
     principals {
       type        = "Service"
       identifiers = ["events.amazonaws.com"]
     }
   }
 }

data "aws_iam_policy_document" "invoke_step_function_role" {
   version = "2012-10-17"
   statement {
     effect    = "Allow"
     actions   = ["states:StartExecution"]
     resources = [
       "${aws_sfn_state_machine.sfn_state_machine.id}"
      ]
   }
 }

 resource "aws_iam_policy" "invoke_step_function_Role" {
     name   = "${var.environment}_Invokes_step_function_role"
     path   = "/"
     policy = data.aws_iam_policy_document.invoke_step_function_role.json
 }

resource "aws_iam_role" "invoke_step_function" {
    name               = "${var.environment}_AWS_Events_Invoke_Step_Function"   
    assume_role_policy = data.aws_iam_policy_document.invoke_step_function_assume_role.json
    
    tags = merge(
        var.common_tags
    )
 }

 /* Attach policies to IAM role */
resource "aws_iam_role_policy_attachment" "invoke_step_function_attach" {
  role       = aws_iam_role.invoke_step_function.name
  policy_arn = aws_iam_policy.invoke_step_function_Role.arn
}

resource "aws_cloudwatch_event_target" "step-function-cloudwatch-rule-target" {
  rule     = aws_cloudwatch_event_rule.step-function-cloudwatch-rule.name
  arn      = aws_sfn_state_machine.sfn_state_machine.id
  role_arn = aws_iam_role.invoke_step_function.arn
}