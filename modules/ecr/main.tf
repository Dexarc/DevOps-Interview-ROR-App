resource "aws_ecr_repository" "repo" {
  name                 = "${var.project_name}-${var.environment}-${var.name_suffix}"
  image_tag_mutability = "MUTABLE"

  force_delete = var.force_delete

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

resource "aws_ecr_lifecycle_policy" "lifecycle" {
  repository = aws_ecr_repository.repo.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "Expire all images older than 5 days",
      "selection": {
        "tagStatus": "any",
        "countType": "sinceImagePushed",
        "countUnit": "days",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}
