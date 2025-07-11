variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where RDS will be created"
  type        = string
}

variable "db_subnet_group_name" {
  description = "Name of the DB subnet group"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_master_username_value" {
  description = "Master username for the database"
  type        = string
  default     = "postgres"
}

variable "kms_rds_key_arn" {
  description = "ARN of the KMS key for RDS encryption"
  type        = string
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate with the RDS instance"
  type        = list(string)
}