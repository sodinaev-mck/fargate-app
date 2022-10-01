data "aws_subnet" "foo" {
  id = var.private_subnets[0]
}
data "aws_vpc" "this" {
  filter {
    name   = "vpc-id"
    values = [data.aws_subnet.foo.vpc_id]
  }
}