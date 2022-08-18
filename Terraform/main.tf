locals {
  tags = {
    terraform = "1.1.9"
    Author = "Brayan Martinez"
  }

  region = "us-east-1"
  account_id = "143407689206"
  public_subnets = ["subnet-0b179ac46e2e95f4d", "subnet-02813e95458a12ba7"]
  private_subnets = ["subnet-c51e359a", "subnet-ec9baecd"]
  vpc_id = "vpc-98344ee5"
}

terraform {
  required_version = ">= 1.0.1"
}

provider "aws" {
  region = local.region
}

resource "aws_ecr_repository" "backend" {
  name                 = "backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "reverseproxy" {
  name                 = "bar"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "frontend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecs_task_definition" "frontend_service" {
  family                = "frontend-service"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  container_definitions = data.template_file.task_definitions_frontend_service.rendered
  cpu                   = 256
  memory                = 512
  execution_role_arn    = aws_iam_role.aws_ecs_task_definition.arn

  tags =local.tags
}

data "template_file" "task_definitions_frontend_service" {
  template = file("${path.module}/task_definitions/default_ec2.json")

  vars = {
    containerPort = tonumber(4200)
    image_name    = aws_ecr_repository.frontend.name
    service_name  = "frontend-service"
    account_id    = local.account_id
    region        = local.region
  }
}

module "services" {
  source = "./service"
  elb_subnets = local.private_subnets
  elb_vpc = local.vpc_id

  elb_sg_ingress_rules = [
    {
      description = "load blancer"
      from_port   = 80
      to_port     = 80
      cidr_blocks = ["0.0.0.0/0"]
      protocol    = "tcp"
    }
  ]

  services = [
    {
      name = "frontend-service"
      task_definition = aws_ecs_task_definition.frontend_service.arn
      port = "4200"

      backend_protocol  = "HTTP"
      backend_port      = 80
      target_type       = "ip"
      network_configuration =[{
        subnets = local.private_subnets
      }]

      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 20
        protocol            = "HTTP"
        matcher             = "200"
      }
    },
  ]
}

