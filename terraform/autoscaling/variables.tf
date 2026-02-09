variable "ami_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "app_sg_id" {
  type = string
}

variable "db_secret_arn" {
  type = string
}

variable "db_endpoint" {
  type = string
}

variable "instance_type" {
  default = "t3.micro"
}

variable "region" {
  type = string
}
