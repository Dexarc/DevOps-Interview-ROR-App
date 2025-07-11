# --- General Variables ---
variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
}

# --- Networking Variables ---
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
}

variable "availability_zone_count" {
  description = "Number of availability zones to use"
  type        = number
}

variable "public_subnet_count" {
  description = "Number of public subnets"
  type        = number
}

variable "private_subnet_count" {
  description = "Number of private subnets"
  type        = number
}

variable "single_nat_gateway" {
  description = "Use a single NAT Gateway for all private subnets"
  type        = bool
}

# --- RDS Variables ---
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "db_name" {
  description = "Name of the database"
  type        = string
}

variable "db_master_username" {
  description = "Master username for the database"
  type        = string
}

variable "db_master_username_value" {
  description = "Master username for the database"
  type        = string
}

variable "kms_rds_key_arn" {
  description = "ARN of the KMS key for RDS encryption"
  type        = string
}

variable "apply_immediately" {
  description = "Apply changes immediately"
  type        = bool
}

variable "rds_apply_immediately" {
  description = "Apply RDS changes immediately"
  type        = bool
}