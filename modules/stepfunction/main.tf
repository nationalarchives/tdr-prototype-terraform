resource "aws_sfn_state_machine" "sfn_state_machine" {
  name = var.step_function_name
  role_arn = "${aws_iam_role.iam_for_sfn.arn}" //"aws:iam::247222723249:role/service-role/TestS3Role"
  definition = <<EOF ""

  tag = {
    Name = var.tag_name
  }
}