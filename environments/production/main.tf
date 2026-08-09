locals {
  common_tags = {
    Project     = var.project
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

module "vpc" {
  source = "../../modules/vpc"

  project     = var.project
  environment = var.environment

  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs

  common_tags = local.common_tags
}

module "alb_sg" {
  source = "../../modules/security-group"

  project     = var.project
  environment = var.environment
  name        = "alb"

  description = "Security group for Application Load Balancer"

  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow HTTP from Internet"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  common_tags = local.common_tags
}

module "ec2_sg" {
  source = "../../modules/security-group"

  project     = var.project
  environment = var.environment
  name        = "ec2"

  description = "Security group for application EC2 instances"

  vpc_id = module.vpc.vpc_id

  ingress_rules = [
    {
      from_port       = 80
      to_port         = 80
      protocol        = "tcp"
      security_groups = [module.alb_sg.security_group_id]
      description     = "Allow HTTP from ALB"
    }
  ]

  egress_rules = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]

  common_tags = local.common_tags
}

module "ec2_iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment
  name        = "ec2"

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]

  common_tags = local.common_tags
}

module "alb" {
  source = "../../modules/alb"

  project     = var.project
  environment = var.environment
  name        = "app"

  vpc_id            = module.vpc.vpc_id
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.alb_sg.security_group_id

  common_tags = local.common_tags
}

module "asg" {
  source = "../../modules/asg"

  project     = var.project
  environment = var.environment
  name        = "app"

  ami_id        = var.ami_id
  instance_type = var.instance_type

  subnet_ids            = module.vpc.private_subnet_ids
  security_group_id     = module.ec2_sg.security_group_id
  instance_profile_name = module.ec2_iam.instance_profile_name

  target_group_arns = [
    module.alb.target_group_arn
  ]

  desired_capacity = var.desired_capacity
  min_size         = var.min_size
  max_size         = var.max_size

  common_tags = local.common_tags
}