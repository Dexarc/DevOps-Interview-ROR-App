variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where ECS will be created"
  type        = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group for the load balancer"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  type        = string
}

variable "ecr_ror_image" {
  description = "ECR image URI for Rails application"
  type        = string
}

variable "ecr_nginx_image" {
  description = "ECR image URI for Nginx"
  type        = string
}

variable "rds_endpoint" {
  description = "RDS endpoint"
  type        = string
}

variable "rds_db_name" {
  description = "The name of the RDS database"
  type        = string
}

variable "rds_username" {
  description = "RDS username"
  type        = string
}

variable "rds_password" {
  description = "RDS password"
  type        = string
}

variable "s3_bucket" {
  description = "S3 bucket name"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}

variable "security_group_ids" {
  description = "List of security group IDs to associate with the ECS service"
  type        = list(string)
}

variable "lb_dns_name" {
  description = "DNS name of the load balancer"
  type        = string
}