# --- Data Sources ---
data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

# --- Networking ---
module "networking" {
  source                  = "../../modules/networking"
  project_name            = var.project_name
  environment             = var.environment
  vpc_cidr                = var.vpc_cidr
  availability_zone_count = var.availability_zone_count
  public_subnet_count     = var.public_subnet_count
  private_subnet_count    = var.private_subnet_count
  single_nat_gateway      = var.single_nat_gateway
  tags                    = var.tags
}

# --- S3 ---
module "s3" {
  source       = "../../modules/s3"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

# --- IAM ---
module "iam" {
  source         = "../../modules/iam"
  project_name   = var.project_name
  environment    = var.environment
  s3_bucket_name = module.s3.bucket_name
  tags           = var.tags
}

# --- ECR Repos ---
module "ecr_rails" {
  source       = "../../modules/ecr"
  name_suffix  = "rails"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

module "ecr_nginx" {
  source       = "../../modules/ecr"
  name_suffix  = "nginx"
  project_name = var.project_name
  environment  = var.environment
  tags         = var.tags
}

# --- RDS ---
module "rds" {
  source = "../../modules/rds"

  project_name             = var.project_name
  environment              = var.environment
  vpc_id                   = module.networking.vpc_id
  db_subnet_group_name     = module.networking.db_subnet_group_name
  db_instance_class        = var.db_instance_class
  db_name                  = var.db_name
  db_master_username_value = var.db_master_username
  kms_rds_key_arn          = var.kms_rds_key_arn
  apply_immediately        = var.rds_apply_immediately
  vpc_security_group_ids   = [module.networking.rds_security_group_id]
  tags                     = var.tags
}

# --- ALB ---
module "alb" {
  source         = "../../modules/alb"
  project_name   = var.project_name
  environment    = var.environment
  vpc_id         = module.networking.vpc_id
  public_subnets = module.networking.public_subnet_ids
  alb_sg_id      = module.networking.alb_security_group_id # Fixed: Pass as string
  tags           = var.tags
}

# --- ECS ---
module "ecs" {
  source             = "../../modules/ecs"
  project_name       = var.project_name
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.networking.vpc_id
  security_group_ids = [module.networking.ecs_security_group_id]
  lb_dns_name        = module.alb.dns_name

  ecr_ror_image   = module.ecr_rails.ecr_repository_url
  ecr_nginx_image = module.ecr_nginx.ecr_repository_url

  rds_endpoint = module.rds.rds_endpoint
  rds_username = module.rds.rds_username
  rds_password = module.rds.rds_password
  rds_db_name  = module.rds.rds_db_name

  s3_bucket       = module.s3.bucket_name
  private_subnets = module.networking.private_subnet_ids

  ecs_execution_role_arn = module.iam.ecs_execution_role_arn
  ecs_task_role_arn      = module.iam.ecs_task_role_arn
  target_group_arn       = module.alb.target_group_arn
}