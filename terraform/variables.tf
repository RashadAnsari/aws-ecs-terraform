variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "default_tags" {
  type        = map(string)
  description = "AWS default tags"
  default     = {}
}

variable "app_name" {
  type        = string
  description = "Application name"
  default     = "go-app"
}

variable "app_env" {
  type        = string
  description = "Application environment"
  default     = "production"
}

variable "app_port" {
  type        = number
  description = "Application port"
  default     = 8080
}

# variable "app_domain" {
#   type        = string
#   description = "Application domain"
# }

variable "app_count" {
  type        = string
  description = "Desired application count"
  default     = 1
}

variable "vpc_cidr" {
  type        = string
  description = "AWS VPC cidr"
  default     = "10.0.0.0/16"
}

variable "docker_image_tag" {
  type        = string
  description = "App docker image tag"
  default     = "latest"
}
