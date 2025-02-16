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
    Version = "2012-10-17",
    Statement = [
      # 1️⃣ Allow App Runner to pull images from ECR
      {
        Sid    = "AllowAppRunnerPull",
        Effect = "Allow",
        Principal = {
          Service = "apprunner.amazonaws.com"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:ListImages",
          "ecr:DescribeRepositories"
        ],
        Resource = aws_ecr_repository.ecr.arn
      },

      # 2️⃣ Allow the IAM Role to pull images from ECR
      {
        Sid    = "AllowAppRunnerRolePull",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:role/${var.prefix}-AppRunnerServiceRole"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:ListImages",
          "ecr:DescribeRepositories"
        ],
        Resource = aws_ecr_repository.ecr.arn
      },

      # 3️⃣ Allow all IAM users and services to get Authorization Token (Mandatory)
      {
        Sid    = "AllowECRLogin",
        Effect = "Allow",
        Principal = "*",
        Action = [
          "ecr:GetAuthorizationToken"
        ],
        Resource = "*"
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