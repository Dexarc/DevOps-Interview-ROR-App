# RDS Instance Outputs
output "rds_endpoint" {
  description = "RDS instance endpoint without port"
  value       = split(":", aws_db_instance.main.endpoint)[0]
}

output "rds_port" {
  description = "The RDS instance port"
  value       = aws_db_instance.main.port
}

output "rds_db_name" {
  description = "The RDS database name"
  value       = aws_db_instance.main.db_name
}

output "rds_username" {
  description = "The RDS master username"
  value       = aws_db_instance.main.username
}

output "rds_password" {
  description = "The RDS master password"
  value       = random_password.db_master_password.result
  sensitive   = true
}

output "rds_instance_id" {
  description = "The RDS instance ID"
  value       = aws_db_instance.main.id
}

output "rds_security_group_id" {
  description = "The RDS security group ID"
  value       = tolist(aws_db_instance.main.vpc_security_group_ids)[0]
}

output "db_parameter_store_path" {
  description = "SSM parameter store path for RDS password"
  value       = aws_ssm_parameter.db_password.name
}