resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-${var.environment}-ecs-cluster"
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-${var.environment}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = var.ecs_execution_role_arn
  task_role_arn            = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "rails_app",
      image     = var.ecr_ror_image,
      portMappings = [{ containerPort = 3000 }],
      essential = true,
      environment = [
        { name = "RDS_ENDPOINT", value = var.rds_endpoint },
        { name = "RDS_USERNAME", value = var.rds_username },
        { name = "RDS_PASSWORD", value = var.rds_password },
        { name = "S3_BUCKET",   value = var.s3_bucket },
        { name = "RAILS_ENV",  value = var.environment }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "rails"
        }
      }
    },
    {
      name      = "nginx",
      image     = var.ecr_nginx_image,
      portMappings = [{ containerPort = 80 }],
      essential = true,
      dependsOn = [{ containerName = "rails_app", condition = "START" }],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "nginx"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "${var.project_name}-${var.environment}-ecs-service"
  cluster         = aws_ecs_cluster.this.id
  launch_type     = "FARGATE"
  desired_count   = 1
  task_definition = aws_ecs_task_definition.this.arn

  network_configuration {
    subnets          = var.private_subnets
    security_groups  = var.security_group_ids
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = "nginx"
    container_port   = 80
  }

  depends_on = [aws_ecs_task_definition.this]
}