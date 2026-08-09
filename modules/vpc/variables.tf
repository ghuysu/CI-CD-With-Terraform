variable "project" {
    description = "Project Name"
    type        = string
}

variable "environment" {
    description = "Environment Name"
    type        = string
}

variable "vpc_cidr" {
    description = "CIDR block for the VPC"
    type        = string
}

variable "availability_zones" {
    description = "List of availability zones to deploy the subnets"
    type        = list(string)
}

variable "public_subnet_cidrs" {
    description = "List of CIDR blocks for public subnets"
    type        = list(string)
}

variable "private_subnet_cidrs" {
    description = "List of CIDR blocks for private subnets"
    type        = list(string)
}

variable "enable_nat_gateway" {
    description = "Flag to enable NAT Gateway for private subnets"
    type        = bool
    default     = false
}

variable "common_tags" {
    description = "Common tags to apply to all resources"
    type        = map(string)
    default     = {}
}