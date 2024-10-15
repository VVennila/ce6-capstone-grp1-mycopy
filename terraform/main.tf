variable "environment" {
  description = "The deployment environment (dev, stage, prod)"
  type        = string
}

locals {
  prefix = "ven-${var.environment}"  # Append environment to prefix
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "aws_ecr_repository" "ecr" {
  name         = "${local.prefix}-ecr"  # ECR name will be unique per environment
  force_delete = true                    # Allows the repository to be deleted even if it contains images
}

module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.9.0"

  cluster_name = "${local.prefix}-ecs"  # ECS cluster name will be unique per environment

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }

  services = {
    ven = { # ECS Task and Service configuration
      cpu    = 512
      memory = 1024
      container_definitions = {
        ven-ecs-container = {
          essential = true
          image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${local.prefix}-ecr:latest"  # Image name will include the environment
          port_mappings = [
            {
              containerPort = 8080
              protocol      = "tcp"
            }
          ]
        }
      }
      assign_public_ip = true
      subnet_ids       = flatten(data.aws_subnets.public.ids)
      security_group_ids = [module.ecs_sg.security_group_id]  # Reference to security group created in the module below
    }
  }
}

module "ecs_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.1.0"

  name        = "${local.prefix}-ecs-sg"  # Security Group name will be unique per environment
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]  # Allow incoming traffic from anywhere
  ingress_rules       = ["http-8080-tcp"]  # Allow HTTP traffic on port 8080
  egress_rules        = ["all-all"]  # Allow all outgoing traffic
}
