variable "region" {
  description = "AWS region"
  default     = "ca-central-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of public subnet CIDR blocks"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of private subnet CIDR blocks"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "azs" {
  description = "List of availability zones"
  default     = ["ca-central-1a", "ca-central-1b"]
}

variable "db_name" {
  description = "Database name"
  default     = "demo_db"
}

variable "db_instance_class" {
  description = "RDS instance class"
  default     = "db.t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the application instances"
  # Valid Amazon Linux 2023 AMI in ca-central-1
  default     = "ami-07f1d29713d3273b1" 
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t3.micro"
}

variable "frontend_bucket_name" {
  description = "Name of the S3 bucket for frontend"
  default     = "three-tier-demo-frontend-rishi"
}
