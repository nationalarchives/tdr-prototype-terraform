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
       aws_sfn_state_machine.sfn_state_machine.id
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
