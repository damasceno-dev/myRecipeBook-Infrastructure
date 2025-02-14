# IAM Role for App Runner Authentication
resource "aws_iam_role" "app_runner_auth_role" {
  name = "${var.prefix}-app-runner-auth-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "apprunner.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Role for App Runner Execution (needed for pulling images)
resource "aws_iam_role" "app_runner_execution_role" {
  name = "${var.prefix}-app-runner-execution-role"

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
  name        = "${var.prefix}-app-runner-policy"
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
        Resource = var.repository_arn
      },
      {
        Effect   = "Allow",
        Action   = ["ecr:GetAuthorizationToken"],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:PassRole"
        ],
        Resource = aws_iam_role.app_runner_execution_role.arn
      }
    ]
  })
}

# Attach App Runner Policy to Execution Role
resource "aws_iam_role_policy_attachment" "app_runner_execution_policy_attach" {
  role       = aws_iam_role.app_runner_execution_role.name
  policy_arn = aws_iam_policy.app_runner_policy.arn
}

# AWS App Runner Service
resource "aws_apprunner_service" "app" {
  service_name = "${var.prefix}-app-runner"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.app_runner_auth_role.arn
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
    instance_role_arn = aws_iam_role.app_runner_execution_role.arn # ✅ Attach execution role
  }

  observability_configuration {
    observability_enabled = false
  }

  tags = {
    Name = "${var.prefix}-app-runner"
    IAC  = "True"
  }
}