resource "aws_vpc" "tkTest" {
  cidr_block = var.cidr

  tags = {
    Name      = var.tag_name
    Terraform = true
  }
}