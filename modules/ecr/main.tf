resource "aws_ecr_repository" "repo" {
  name                 = "${var.project_name}-${var.environment}-${var.name_suffix}"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = merge({
    Name = "${var.project_name}-${var.environment}-${var.name_suffix}-ecr"
  }, var.tags)
}
