locals {
  name = "${var.app_name}-${var.app_env}"
  azs  = slice(data.aws_availability_zones.available.names, 0, 3)
}

data "aws_ssm_parameter" "ecs_optimized_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
}

data "aws_ecr_repository" "app" {
  name = local.name
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 1)]
  public_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 101)]

  enable_nat_gateway = true
  single_nat_gateway = true
}

module "alb_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.ecs_cluster_name}-alb-sg"
  vpc_id = module.vpc.vpc_id

  ingress_rules       = ["http-80-tcp", "https-443-tcp", "all-icmp"]
  ingress_cidr_blocks = ["0.0.0.0/0"]

  egress_rules       = ["all-all"]
  egress_cidr_blocks = module.vpc.private_subnets_cidr_blocks
}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 8.0"

  name = "${var.ecs_cluster_name}-alb"

  load_balancer_type = "application"

  vpc_id          = module.vpc.vpc_id
  subnets         = module.vpc.public_subnets
  security_groups = [module.alb_sg.security_group_id]

  http_tcp_listeners = [
    # {
    #   port        = 80
    #   protocol    = "HTTP"
    #   action_type = "redirect"
    #   redirect = {
    #     port        = "443"
    #     protocol    = "HTTPS"
    #     status_code = "HTTP_301"
    #   }
    # },
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    },
  ]

  # https_listeners = [
  #   {
  #     port            = 443
  #     protocol        = "HTTPS"
  #     certificate_arn = module.acm.acm_certificate_arn
  #   },
  # ]

  # https_listener_rules = [
  #   {
  #     https_listener_index = 0
  #     actions = [
  #       {
  #         type               = "forward"
  #         target_group_index = 0
  #       },
  #     ]
  #     conditions = [
  #       {
  #         host_headers = [var.app_domain]
  #       },
  #     ]
  #   },
  #   {
  #     https_listener_index = 0
  #     actions = [
  #       {
  #         type               = "forward"
  #         target_group_index = 1
  #       },
  #     ]
  #     conditions = [
  #       {
  #         host_headers = ["api.${var.app_domain}"]
  #       },
  #     ]
  #   },
  # ]

  target_groups = [
    {
      backend_protocol = "HTTP"
      backend_port     = var.app_port
      target_type      = "ip"
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/health"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
    },
  ]
}

module "autoscaling_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name   = "${var.ecs_cluster_name}-autoscaling-sg"
  vpc_id = module.vpc.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.alb_sg.security_group_id
    },
    {
      rule                     = "all-icmp"
      source_security_group_id = module.alb_sg.security_group_id
    },
  ]
  number_of_computed_ingress_with_source_security_group_id = 3

  egress_rules = ["all-all"]
}

module "autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 6.0"

  for_each = {
    on-demand = {
      instance_type              = var.ecs_ec2_instance_type
      use_mixed_instances_policy = false
      mixed_instances_policy     = {}
      user_data                  = <<-EOT
        #!/bin/bash
        cat <<'EOF' >> /etc/ecs/ecs.config
        ECS_CLUSTER=${var.ecs_cluster_name}
        ECS_LOGLEVEL=warning
        ECS_CONTAINER_INSTANCE_TAGS=${jsonencode(var.default_tags)}
        ECS_ENABLE_TASK_IAM_ROLE=true
        EOF
      EOT
    }
  }

  name = "${var.ecs_cluster_name}-${each.key}-autoscaling"

  image_id      = jsondecode(data.aws_ssm_parameter.ecs_optimized_ami.value)["image_id"]
  instance_type = each.value.instance_type

  vpc_zone_identifier = module.vpc.private_subnets
  security_groups     = [module.autoscaling_sg.security_group_id]

  user_data = base64encode(each.value.user_data)

  ignore_desired_capacity_changes = true

  create_iam_instance_profile = true
  iam_role_name               = "${var.ecs_cluster_name}-iam"
  iam_role_policies = {
    AmazonSSMManagedInstanceCore        = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    AmazonEC2ContainerServiceforEC2Role = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
  }

  health_check_type = "EC2"

  min_size         = var.ecs_ec2_min_count
  desired_capacity = var.ecs_ec2_desired_count
  max_size         = var.ecs_ec2_max_count

  autoscaling_group_tags = {
    AmazonECSManaged = true
  }

  protect_from_scale_in = true

  use_mixed_instances_policy = each.value.use_mixed_instances_policy
  mixed_instances_policy     = each.value.mixed_instances_policy
}

module "ecs_cluster" {
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.0"

  cluster_name = var.ecs_cluster_name

  create_cloudwatch_log_group            = var.create_cloudwatch_log_group
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days

  default_capacity_provider_use_fargate = false
  autoscaling_capacity_providers = {
    on-demand = {
      auto_scaling_group_arn         = module.autoscaling["on-demand"].autoscaling_group_arn
      managed_termination_protection = var.ecs_cluster_scaling ? "ENABLED" : "DISABLED"

      managed_scaling = {
        minimum_scaling_step_size = 1
        maximum_scaling_step_size = 5
        status                    = var.ecs_cluster_scaling ? "ENABLED" : "DISABLED"
        target_capacity           = 80
      }

      default_capacity_provider_strategy = {
        weight = 100
      }
    }
  }
}

module "ecs_service" {
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.0"

  name        = local.name
  cluster_arn = module.ecs_cluster.arn

  requires_compatibilities = ["EC2"]
  capacity_provider_strategy = {
    on-demand = {
      capacity_provider = module.ecs_cluster.autoscaling_capacity_providers["on-demand"].name
      weight            = 100
    }
  }

  cpu    = var.app_cpu
  memory = var.app_memory

  container_definition_defaults = {
    enable_cloudwatch_logging              = var.create_cloudwatch_log_group
    create_cloudwatch_log_group            = var.create_cloudwatch_log_group
    cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  }

  container_definitions = {
    (var.app_name) = {
      image = "${data.aws_ecr_repository.app.repository_url}:${var.docker_image_tag}"
      port_mappings = [
        {
          name          = var.app_name
          containerPort = var.app_port
          protocol      = "tcp"
        }
      ]
    }
  }

  load_balancer = {
    service = {
      target_group_arn = element(module.alb.target_group_arns, 0)
      container_name   = var.app_name
      container_port   = var.app_port
    }
  }

  subnet_ids = module.vpc.private_subnets
  security_group_rules = {
    alb_http_ingress = {
      type                     = "ingress"
      from_port                = var.app_port
      to_port                  = var.app_port
      protocol                 = "tcp"
      source_security_group_id = module.alb_sg.security_group_id
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}
