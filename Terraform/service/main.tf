resource "aws_ecs_cluster" "this" {
  name               = "test"
  tags = var.tags
}

resource "aws_ecs_service" "this" {
  count = length(var.services) != 0 ? length(var.services) : 0

  name                               = var.services[count.index].name
  desired_count                      = lookup(var.services[count.index], "desired_count", 1)
  cluster                            = aws_ecs_cluster.this.id
  iam_role                           = aws_iam_role.this.arn 
  task_definition                    = var.services[count.index].task_definition
  enable_ecs_managed_tags            = lookup(var.services[count.index], "enable_ecs_managed_tags", true)
  propagate_tags                     = lookup(var.services[count.index], "propagate_tags", "TASK_DEFINITION")
  scheduling_strategy                = lookup(var.services[count.index], "scheduling_strategy", "REPLICA")
  deployment_maximum_percent         = lookup(var.services[count.index], "deployment_maximum_percent", null)
  deployment_minimum_healthy_percent = lookup(var.services[count.index], "deployment_minimum_healthy_percent", null)
  enable_execute_command             = lookup(var.services[count.index], "enable_execute_command", null)
  force_new_deployment               = lookup(var.services[count.index], "force_new_deployment", null)
  health_check_grace_period_seconds  = lookup(var.services[count.index], "health_check_grace_period_seconds", null)
  launch_type                        = lookup(var.services[count.index], "launch_type", "FARGATE")

  dynamic "load_balancer" {
    for_each = lookup(var.services[count.index], "create_alb", true) ? [1] : [] 

    content {
      target_group_arn = element(concat(module.alb.target_group_arns, [""]), count.index)
      container_name   = var.services[count.index].name
      container_port   = var.services[count.index].port
    }
  }

   dynamic "network_configuration" {
    for_each = lookup(var.services[count.index], "network_configuration", [])

    content {
      subnets          = network_configuration.value["subnets"]
      security_groups  = lookup(network_configuration.value, "security_groups", null)
      assign_public_ip = lookup(network_configuration.value, "assign_public_ip", false)
    }
  }

  tags = var.tags
}

module "alb" {
  source               = "terraform-aws-modules/alb/aws"
  version              = "6.5"
  create_lb            = true
  name                 = "test-ecs-services"
  load_balancer_type   = "application"
  vpc_id               = var.elb_vpc
  subnets              = var.elb_subnets
  security_groups      = [aws_security_group.this.id]
  target_groups        = var.services

  http_tcp_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  tags = var.tags
}

resource "aws_security_group" "this" {
  name        = "test_ecs_services"
  description = "Security Group for ALB"
  vpc_id      = var.elb_vpc

  dynamic "ingress" {
    for_each = var.elb_sg_ingress_rules

    content {
      description = ingress.value["description"]
      from_port   = ingress.value["from_port"]
      to_port     = ingress.value["to_port"]
      cidr_blocks = ingress.value["cidr_blocks"]
      protocol    = ingress.value["protocol"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}