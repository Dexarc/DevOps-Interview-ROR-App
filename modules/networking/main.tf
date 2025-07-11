# Get current region and AZs
data "aws_region" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.availability_zone_count)
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = merge({
    Name = "${var.project_name}-${var.environment}-vpc"
  }, var.tags)
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge({
    Name = "${var.project_name}-${var.environment}-igw"
  }, var.tags)
}

# Public Subnets (for ALB only)
resource "aws_subnet" "public" {
  count = var.public_subnet_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = merge({
    Name    = "${var.project_name}-${var.environment}-public-subnet-${count.index + 1}"
    Type    = "public"
    Purpose = "LoadBalancer"
  }, var.tags)
}

# Private ECS Subnets
resource "aws_subnet" "ecs" {
  count = var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = local.azs[count.index]
  tags = merge({
    Name    = "${var.project_name}-${var.environment}-ecs-subnet-${count.index + 1}"
    Type    = "private"
    Purpose = "ECS"
  }, var.tags)
}

# Private RDS Subnets
resource "aws_subnet" "rds" {
  count = var.private_subnet_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 20)
  availability_zone = local.azs[count.index]
  tags = merge({
    Name    = "${var.project_name}-${var.environment}-rds-subnet-${count.index + 1}"
    Type    = "private"
    Purpose = "RDS"
  }, var.tags)
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds" {
  name       = "${var.project_name}-${var.environment}-rds-subnet-group"
  subnet_ids = aws_subnet.rds[*].id
  tags = merge({
    Name = "${var.project_name}-${var.environment}-rds-subnet-group"
  }, var.tags)
}

# NAT Gateways + EIPs
resource "aws_eip" "nat" {
  count  = var.single_nat_gateway ? 1 : var.public_subnet_count
  domain = "vpc"
  depends_on = [aws_internet_gateway.main]
  tags = merge({
    Name = "${var.project_name}-${var.environment}-nat-eip-${count.index + 1}"
  }, var.tags)
}

resource "aws_nat_gateway" "main" {
  count         = var.single_nat_gateway ? 1 : var.public_subnet_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  depends_on    = [aws_internet_gateway.main]
  tags = merge({
    Name = "${var.project_name}-${var.environment}-nat-${count.index + 1}"
  }, var.tags)
}

# Route Tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge({
    Name = "${var.project_name}-${var.environment}-public-rt"
  }, var.tags)
}

resource "aws_route_table" "ecs" {
  count  = var.private_subnet_count
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[var.single_nat_gateway ? 0 : count.index].id
  }
  tags = merge({
    Name = "${var.project_name}-${var.environment}-ecs-rt-${count.index + 1}"
  }, var.tags)
}

resource "aws_route_table" "rds" {
  count  = var.private_subnet_count
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[var.single_nat_gateway ? 0 : count.index].id
  }
  tags = merge({
    Name = "${var.project_name}-${var.environment}-rds-rt-${count.index + 1}"
  }, var.tags)
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "ecs" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.ecs[count.index].id
  route_table_id = aws_route_table.ecs[count.index].id
}

resource "aws_route_table_association" "rds" {
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.rds[count.index].id
  route_table_id = aws_route_table.rds[count.index].id
}

# ====================
# SECURITY GROUPS
# ====================

# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }, var.tags)
}

# ECS Security Group
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs-sg"
  description = "Security group for ECS tasks"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "App port from ALB"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.project_name}-${var.environment}-ecs-sg"
  }, var.tags)
}

# RDS Security Group
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.environment}-rds-sg"
  description = "Security group for RDS database"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "PostgreSQL from ECS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs.id]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge({
    Name = "${var.project_name}-${var.environment}-rds-sg"
  }, var.tags)
}