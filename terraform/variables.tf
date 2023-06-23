# ====================
# AWS variables
# ====================

variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "default_tags" {
  type        = map(string)
  description = "AWS default tags"
  default     = {}
}

variable "vpc_cidr" {
  type        = string
  description = "AWS VPC cidr"
  default     = "10.0.0.0/16"
}

variable "ecs_cluster_name" {
  type        = string
  description = "AWS ECS cluster name"
  default     = "my-cluster-prod"
}

variable "ecs_ec2_instance_type" {
  type        = string
  description = "AWS EC2 instance type for ECS cluster"
  default     = "t3.micro"
}

variable "create_cloudwatch_log_group" {
  type        = bool
  description = "Determines whether a log group is created"
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "Number of days to retain log events"
  default     = 7
}

# variable "loadbalancer_domain" {
#   type        = string
#   description = "Loadbalancer domain"
# }

# ====================
# App variables
# ====================

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "go-app"
}

variable "app_env" {
  type        = string
  description = "Application environment"
  default     = "prod"
}

variable "app_port" {
  type        = number
  description = "Application port"
  default     = 8080
}

variable "app_cpu" {
  type        = number
  description = "Application cpu"
  default     = 512
}

variable "app_memory" {
  type        = number
  description = "Application memory"
  default     = 512
}

variable "min_app_count" {
  type        = string
  description = "Minimum application count"
  default     = 1 # FIXME
}

variable "desired_app_count" {
  type        = string
  description = "Desired application count"
  default     = 1 # FIXME
}

variable "max_app_count" {
  type        = string
  description = "Maximum application count"
  default     = 5
}

variable "docker_image_tag" {
  type        = string
  description = "Application docker image tag"
  default     = "latest"
}
