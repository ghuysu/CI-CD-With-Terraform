variable "project" {
  description = "The name of the project"
  type = string
}

variable "environment" {
  description = "The environment name"
  type = string
}

variable "name" {
  description = "The name of the Auto Scaling Group"
  type = string
}

variable "ami_id" {
  description = "The AMI ID for the instances"
  type = string
}

variable "instance_type" {
  description = "The instance type for the instances"
  type = string
}

variable "key_name" {
  description = "The name of the key pair for the instances"
  type    = string
  default = null
}

variable "subnet_ids" {
  description = "The list of subnet IDs for the Auto Scaling Group"
  type = list(string)
}

variable "security_group_id" {
  description = "The security group ID for the instances"
  type = string
}

variable "instance_profile_name" {
  description = "The name of the instance profile"
  type = string
}

variable "target_group_arns" {
  description = "The list of target group ARNs"
  type = list(string)
}

variable "desired_capacity" {
  description = "The desired capacity for the Auto Scaling Group"
  type = number
}

variable "min_size" {
  description = "The minimum size for the Auto Scaling Group"
  type = number
}

variable "max_size" {
  description = "The maximum size for the Auto Scaling Group"
  type = number
}

variable "user_data" {
  description = "The user data for the instances"
  type    = string
  default = ""
}

variable "common_tags" {
  description = "The common tags for the resources"
  type    = map(string)
  default = {}
}