# IAM Role for App Runner Authentication (pulls from ECR)
resource "aws_iam_role" "app_runner_role" {
  name = "${var.prefix}-AppRunnerServiceRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "apprunner.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Role for App Runner Execution (running the app)
resource "aws_iam_role" "app_runner_execution_role" {
  name = "${var.prefix}-AppRunnerExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "apprunner.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for App Runner to access ECR
resource "aws_iam_policy" "app_runner_policy" {
  name        = "${var.prefix}-AppRunnerServicePolicy"
  description = "Policy for AWS App Runner to access ECR"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:GetAuthorizationToken",
          "ecr:ListImages",
          "ecr:DescribeRepositories",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = ["iam:PassRole"],
        Resource = "*"
      }
    ]
  })
}

# Attach IAM Policy to App Runner Execution Role
resource "aws_iam_role_policy_attachment" "app_runner_execution_policy_attach" {
  role       = aws_iam_role.app_runner_execution_role.name
  policy_arn = aws_iam_policy.app_runner_policy.arn
}

# ECR Repository Policy to Allow App Runner to Pull Images
resource "aws_ecr_repository_policy" "app_runner_ecr_policy" {
  repository = var.repository_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow App Runner to pull images from ECR
      {
        Sid    = "AllowAppRunnerPull",
        Effect = "Allow",
        Principal = {
          "Service": "apprunner.amazonaws.com"
        },
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:ListImages",
          "ecr:DescribeRepositories"
        ],
        Resource = var.repository_arn
      }
    ]
  })

  depends_on = [aws_iam_role.app_runner_role]
}

# AWS App Runner Service
resource "aws_apprunner_service" "app" {
  service_name = "${var.prefix}-app-runner"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_role.arn
    }

    image_repository {
      image_identifier      = "${var.repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = "80"
      }
    }
    auto_deployments_enabled = true
  }

  instance_configuration {
    cpu    = "1024"
    memory = "2048"
    instance_role_arn = aws_iam_role.app_runner_execution_role.arn
  }

  observability_configuration {
    observability_enabled = false
  }

  tags = {
    Name = "${var.prefix}-app-runner"
    IAC  = "True"
  }
}