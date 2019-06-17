resource "aws_vpc" "tkTest" {
  cidr_block = "${var.cidr}"

  tags = {
    Name = "${var.vpc_name}"
  }
}