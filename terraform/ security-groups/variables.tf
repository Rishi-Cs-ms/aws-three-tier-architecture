variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "app_port" {
  default = 3000
}

variable "db_port" {
  default = 3306
}
