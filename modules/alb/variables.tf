variable "project" {
    description = "The name of the project"
    type = string
}

variable "environment" {
    description = "The environment name"
    type = string
}

variable "name" {
    description = "The name of the ALB"
    type = string
}

variable "vpc_id" {
    description = "The ID of the VPC"
    type = string
}

variable "subnet_ids" {
    description = "The IDs of the subnets"
    type = list(string)
}

variable "security_group_id" {
    description = "The ID of the security group"
    type = string
}

variable "internal" {
    description = "Whether the ALB is internal"
    type    = bool
    default = false
}

variable "common_tags" {
    description = "Common tags for all resources"
    type    = map(string)
    default = {}
}