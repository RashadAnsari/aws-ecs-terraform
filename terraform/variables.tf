# ====================
# AWS variables
# ====================

variable "region" {
  description = "The AWS region"
  default     = "eu-west-1"
}

variable "default_tags" {
  type        = map(string)
  description = "Default tags for AWS resources"
  default     = {}
}

variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "ecs_cluster_name" {
  type        = string
  description = "The name of the ECS cluster"
  default     = "my-cluster-prod"
}

variable "ecs_ec2_instance_type" {
  type        = string
  description = "The EC2 instance type for the ECS cluster"
  default     = "t3.micro"
}

variable "ecs_ec2_min_count" {
  type        = string
  description = "The minimum number of EC2 instances for the ECS cluster"
  default     = 1
}

variable "ecs_ec2_desired_count" {
  type        = string
  description = "The desired number of EC2 instances for the ECS cluster"
  default     = 2
}

variable "ecs_ec2_max_count" {
  type        = string
  description = "The maximum number of EC2 instances for the ECS cluster"
  default     = 5
}

variable "ecs_cluster_scaling" {
  type        = bool
  description = "Enable or disable ECS cluster autoscaling"
  default     = true
}

variable "create_cloudwatch_log_group" {
  type        = bool
  description = "Determines whether to create a CloudWatch log group"
  default     = true
}

variable "cloudwatch_log_group_retention_in_days" {
  type        = number
  description = "The number of days to retain log events in CloudWatch"
  default     = 7
}

# variable "loadbalancer_domain" {
#   type        = string
#   description = "The domain of the load balancer"
# }

# ====================
# App variables
# ====================

variable "app_name" {
  type        = string
  description = "The name of the application"
  default     = "go-app"
}

variable "app_env" {
  type        = string
  description = "The environment of the application"
  default     = "prod"
}

variable "app_port" {
  type        = number
  description = "The port on which the application listens"
  default     = 8080
}

variable "app_cpu" {
  type        = number
  description = "The CPU units for the application"
  default     = 512
}

variable "app_memory" {
  type        = number
  description = "The memory limit in megabytes for the application"
  default     = 512
}

variable "docker_image_tag" {
  type        = string
  description = "The tag of the Docker image for the application"
  default     = "latest"
}
