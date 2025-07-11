resource "random_password" "db_master_password" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+.?[]{}<>"
  min_lower        = 1
  min_upper        = 1
  min_numeric      = 1
  min_special      = 1
}

resource "aws_ssm_parameter" "db_password" {
  name        = "/${var.project_name}/${var.environment}/rds/password"
  type        = "SecureString"
  value       = random_password.db_master_password.result
  tier        = "Standard"
  description = "RDS Master Password for ${var.project_name}-${var.environment}"
  key_id      = var.kms_rds_key_arn
  tags        = var.tags
}

resource "aws_db_instance" "main" {
  identifier                            = "${var.project_name}-${var.environment}-db"
  engine                                = "postgres"
  engine_version                        = "17.4"
  instance_class                        = var.db_instance_class
  allocated_storage                     = 20
  max_allocated_storage                 = 100
  storage_type                          = "gp2"
  storage_encrypted                     = true
  kms_key_id                            = var.kms_rds_key_arn
  db_name                               = var.db_name
  username                              = var.db_master_username_value
  password                              = random_password.db_master_password.result
  port                                  = 5432
  vpc_security_group_ids                = var.vpc_security_group_ids
  db_subnet_group_name                  = var.db_subnet_group_name
  multi_az                              = true
  publicly_accessible                   = false
  backup_retention_period               = 7
  backup_window                         = "03:00-04:00"
  maintenance_window                    = "sun:04:00-sun:05:00"
  auto_minor_version_upgrade            = true
  skip_final_snapshot                   = true
  deletion_protection                   = false
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  enabled_cloudwatch_logs_exports       = ["postgresql"]
  apply_immediately                     = var.apply_immediately

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db"
  })

  lifecycle {
    ignore_changes = [password]
  }
}