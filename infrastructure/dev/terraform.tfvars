# --- General Variables ---
project_name = "malowtech"
environment  = "dev"
aws_region   = "us-east-1"
tags = {
  Project     = "malowtech"
  Environment = "dev"
  Terraform   = "true"
}

# --- Networking Variables ---
vpc_cidr               = "10.0.0.0/16"
availability_zone_count = 2
public_subnet_count    = 2
private_subnet_count   = 2
single_nat_gateway     = true

# --- RDS Variables ---
db_instance_class       = "db.t3.micro"
db_name                 = "malowtech_dev"
db_master_username      = "postgres"
db_master_username_value = "postgres"
kms_rds_key_arn         = ""
apply_immediately       = true
rds_apply_immediately   = true