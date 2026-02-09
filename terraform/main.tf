terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source          = "./vpc"
  region          = var.region
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  azs             = var.azs
}

module "security_groups" {
  source   = "./security-groups"
  vpc_id   = module.vpc.vpc_id
  app_port = 3000
  db_port  = 3306
}

module "rds" {
  source             = "./rds"
  private_subnet_ids = module.vpc.private_subnet_ids
  rds_sg_id          = module.security_groups.rds_sg_id
  db_name            = var.db_name
  db_instance_class  = var.db_instance_class
}

module "autoscaling" {
  source             = "./autoscaling"
  ami_id             = var.ami_id
  instance_type      = var.instance_type
  private_subnet_ids = module.vpc.private_subnet_ids
  app_sg_id          = module.security_groups.app_sg_id
  db_secret_arn      = module.rds.db_secret_arn
  db_endpoint        = module.rds.rds_endpoint
  region             = var.region
  # Removed frontend_url to break circular dependency
}

module "alb" {
  source             = "./alb"
  vpc_id             = module.vpc.vpc_id
  public_subnet_ids  = module.vpc.public_subnet_ids
  alb_sg_id          = module.security_groups.alb_sg_id
  asg_name           = module.autoscaling.asg_name
}

module "frontend" {
  source       = "./frontend"
  bucket_name  = var.frontend_bucket_name
  alb_dns_name = module.alb.alb_dns_name
}
