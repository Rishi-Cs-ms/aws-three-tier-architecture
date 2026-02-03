variable "vpc_id" {
  type = string
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "rds_sg_id" {
  type = string
}

variable "db_name" {
  default = "appdb"
}

variable "db_instance_class" {
  default = "db.t3.micro"
}

variable "multi_az" {
  default = false
}
