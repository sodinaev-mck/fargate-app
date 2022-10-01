data "aws_subnet" "foo" {
    id = var.subnets[0] 
}

data "aws_vpc" "this" {
    filter {
        name = "vpc-id"
        values = [data.aws_subnet.foo.vpc_id]
    }
}

resource "aws_security_group" "task" {
  name        = "${var.app_name}-ecs-task"
  description = "Fargate service"
  vpc_id      = data.aws_vpc.this.id

    egress {
        from_port = "0"
        to_port = "0"
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

# Rules for the TASK (Targets the LB SG)
resource "aws_security_group_rule" "task_ingress_rule" {
  description              = "Only allow connections from SG ${var.app_name}-lb on port ${var.container_port}"
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = var.lb_sg_id

  security_group_id = aws_security_group.task.id
}