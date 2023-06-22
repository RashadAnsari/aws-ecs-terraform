variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "default_tags" {
  type        = map(string)
  description = "AWS Resource default tags"
  default     = {}
}

# Example: https://cloud-images.ubuntu.com/locator/ec2/
variable "aws_ami" {
  type        = string
  description = "AWS AMI for specified region"
  default     = "ami-06d1a5507784edbad" # eu-west-1
}

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
  description = "Port number for the application"
  default     = 8080
}

variable "app_count" {
  type        = string
  description = "Desired application count"
  default     = 1
}

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_blocks" {
  type        = list(string)
  description = "Available CIDR blocks for public subnets"
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  type        = list(string)
  description = "Available CIDR blocks for private subnets"
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
  ]
}

variable "ssh_public_file" {
  description = "Path to an SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

# variable "autoscale_min" {
#   description = "Minimum autoscale (number of EC2)"
#   default     = 1
# }

# variable "autoscale_max" {
#   description = "Maximum autoscale (number of EC2)"
#   default     = 10
# }

# variable "autoscale_desired" {
#   description = "Desired autoscale (number of EC2)"
#   default     = 4
# }

variable "docker_image_url" {
  description = "Docker image to run in the ECS cluster"
  default     = "<AWS_ACCOUNT_ID>.dkr.ecr.eu-west-1.amazonaws.com/go-app-prod:latest"
}
