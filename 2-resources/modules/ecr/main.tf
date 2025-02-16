resource "aws_ecr_repository" "ecr" {
  name                 = "${var.prefix}-ecr-repository"
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "AES256"
  }

  force_delete = true

  tags = {
    Name = "${var.prefix}-ecr"
    IAC  = "True"
  }
}
resource "aws_ecr_repository_policy" "app_runner_ecr_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    Version   = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowAppRunnerPull",
        Effect    = "Allow",
        Principal = {
          Service = "apprunner.amazonaws.com"
        },
        Action    = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource  = "*"
      }
    ]
  })
}
resource "aws_ecr_lifecycle_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1,
        description  = "Expire untagged images after 7 days",
        selection = {
          tagStatus   = "untagged"
          countType   = "sinceImagePushed"
          countUnit   = "days"
          countNumber = 7
        },
        action = {
          type = "expire"
        }
      }
    ]
  })
}