resource "aws_sfn_state_machine" "sfn_state_machine" {
  name = var.step_function_name

  tag = {
    Name = var.tag_name
  }
}