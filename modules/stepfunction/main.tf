resource "aws_sfn_state_machine" "sfn_state_machine" {
  name       = var.step_function_name
  role_arn   = "arn:aws:iam::247222723249:role/service-role/TestS3Role"
  definition = <<EOF
    {
      "Comment": "A Hello World example of the Amazon States Language using a Pass state",
      "StartAt": "HelloWorld",
      "States": {
        "HelloWorld": {
        "Type": "Pass",
        "Result": "Hello World! - ${var.vpc_id}",
        "End": true
        }
      }
    }
    EOF

  tags = {
    Name      = var.tag_name
    Terraform = true
  }
}