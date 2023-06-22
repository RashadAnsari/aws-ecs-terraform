variable "region" {
  description = "AWS region"
  default     = "eu-west-1"
}

variable "default_tags" {
  type        = map(string)
  description = "AWS Resource default tags"
  default     = {}
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
