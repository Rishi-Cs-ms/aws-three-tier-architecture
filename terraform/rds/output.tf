output "rds_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "db_secret_arn" {
  value = aws_secretsmanager_secret.db_secret.arn
}
