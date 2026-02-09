# Generate DB password
resource "random_password" "db_password" {
  length  = 16
  special = true
  override_special = "!#$%^&*()-_=+[]{}<>:?"
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret" "db_secret" {
  name = "mysql-db-credentials-three-tier-v2"
}

resource "aws_secretsmanager_secret_version" "db_secret_value" {
  secret_id = aws_secretsmanager_secret.db_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
  })
}

# DB Subnet Group (PRIVATE subnets)
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "mysql-private-subnet-group-three-tier"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "mysql-subnet-group"
  }
}

# MySQL RDS
resource "aws_db_instance" "mysql" {
  identifier              = "mysql-app-db"
  engine                  = "mysql"
  engine_version          = "8.0"
  instance_class          = var.db_instance_class
  allocated_storage       = 20
  storage_type            = "gp2"

  db_name                 = var.db_name
  username                = "admin"
  password                = random_password.db_password.result

  multi_az                = var.multi_az
  publicly_accessible     = false
  skip_final_snapshot     = true

  backup_retention_period = 7
  deletion_protection     = false

  vpc_security_group_ids  = [var.rds_sg_id]
  db_subnet_group_name    = aws_db_subnet_group.db_subnet_group.name

  tags = {
    Name = "mysql-rds"
  }
}
