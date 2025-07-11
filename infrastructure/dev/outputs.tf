# --- Networking Outputs ---
output "vpc_id" {
  description = "ID of the VPC"
  value       = module.networking.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = module.networking.vpc_cidr
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.networking.private_subnet_ids  # Fixed: Now available from networking module
}

output "ecs_subnet_ids" {
  description = "List of ECS subnet IDs"
  value       = module.networking.ecs_subnet_ids
}

output "rds_subnet_ids" {
  description = "List of RDS subnet IDs"
  value       = module.networking.rds_subnet_ids
}

# --- RDS Outputs ---
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.rds_endpoint
}

output "rds_port" {
  description = "RDS instance port"
  value       = module.rds.rds_port
}

output "rds_db_name" {
  description = "RDS database name"
  value       = module.rds.rds_db_name
}

output "rds_username" {
  description = "RDS master username"
  value       = module.rds.rds_username
}

# --- ALB Outputs ---
output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = module.alb.alb_dns_name
}

output "alb_zone_id" {
  description = "Zone ID of the load balancer"
  value       = module.alb.alb_zone_id
}

output "target_group_arn" {
  description = "ARN of the target group"
  value       = module.alb.target_group_arn
}

# --- ECS Outputs ---
output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.ecs_cluster_name
}

output "ecs_service_name" {
  description = "Name of the ECS service"
  value       = module.ecs.ecs_service_name
}

# --- ECR Outputs ---
output "ecr_rails_repository_url" {
  description = "URL of the Rails ECR repository"
  value       = module.ecr_rails.ecr_repository_url
}

output "ecr_nginx_repository_url" {
  description = "URL of the Nginx ECR repository"
  value       = module.ecr_nginx.ecr_repository_url
}

# --- S3 Outputs ---
output "s3_bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3.bucket_name
}

# --- IAM Outputs ---
output "ecs_execution_role_arn" {
  description = "ARN of the ECS execution role"
  value       = module.iam.ecs_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ARN of the ECS task role"
  value       = module.iam.ecs_task_role_arn
}