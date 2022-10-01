data "aws_subnet" "foo" {
    id = var.subnets[0] 
}
data "aws_vpc" "this" {
    filter {
        name = "vpc-id"
        values = [data.aws_subnet.foo.vpc_id]
    }
}

resource "aws_security_group" "lb" {
  name        = "${var.app_name}-lb"
  description = "foo"
  vpc_id      = data.aws_vpc.this.id

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}



