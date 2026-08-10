aws_region = "ap-southeast-1"

project     = "terra"
environment = "staging"

vpc_cidr = "10.20.0.0/16"

availability_zones = [
  "ap-southeast-1a",
  "ap-southeast-1b"
]

public_subnet_cidrs = [
  "10.20.1.0/24",
  "10.20.2.0/24"
]

private_subnet_cidrs = [
  "10.20.11.0/24",
  "10.20.12.0/24"
]

instance_type = "t3.micro"

ami_id = "ami-xxxxxxxxxxxxxxxxx"

desired_capacity = 2
min_size         = 1
max_size         = 2