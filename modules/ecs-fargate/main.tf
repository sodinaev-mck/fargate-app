data "aws_region" "this" {}

resource "aws_ecs_cluster" "app" {
  name = var.app_name
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"
      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.this.name
      }
    }

  }

}

resource "aws_cloudwatch_log_group" "this" {
  name = "/fargate/cluster/${var.app_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "service" {
  name = "/fargate/service/${var.app_name}"
  retention_in_days = 7
}


resource "aws_ecs_task_definition" "app" {
  family                   = var.app_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn

  # task_role_arn = aws_iam_role.app_role.arn

  container_definitions = <<DEFINITION
[
  {
    "name": "${var.app_name}",
    "image": "${var.registry_url}:${var.image_tag}",
    "essential": true,
    "portMappings": [
      {
        "protocol": "tcp",
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${aws_cloudwatch_log_group.service.name}",
        "awslogs-region": "${data.aws_region.this.name}",
        "awslogs-stream-prefix": "ecs"
      }
    }
  }
]
DEFINITION
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "${var.app_name}-exec-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]

}

resource "aws_ecs_service" "app" {
  name            = var.app_name
  cluster         = aws_ecs_cluster.app.id
  launch_type     = "FARGATE"
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1

  network_configuration {
    security_groups = [aws_security_group.task.id]
    subnets         = var.subnets
  }

  load_balancer {
    target_group_arn = var.lb_target_id
    container_name   = var.app_name
    container_port   = var.container_port
  }

  # enable_ecs_managed_tags = true
  # propagate_tags          = "SERVICE"

  
  # [after initial apply] don't override changes made to task_definition
  # from outside of terraform (i.e.; fargate cli)
  # lifecycle {
  #   ignore_changes = [task_definition]
  # }
}