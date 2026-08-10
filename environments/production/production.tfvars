aws_region = "ap-southeast-1"

project     = "terraform-with-cicd"
environment = "production"

vpc_cidr = "10.10.0.0/16"

availability_zones = [
  "ap-southeast-1a",
  "ap-southeast-1b"
]

public_subnet_cidrs = [
  "10.10.1.0/24",
  "10.10.2.0/24"
]

private_subnet_cidrs = [
  "10.10.11.0/24",
  "10.10.12.0/24"
]

instance_type = "t3.small"

ami_id = "ami-xxxxxxxxxxxxxxxxx"

desired_capacity = 2
min_size         = 2
max_size         = 4