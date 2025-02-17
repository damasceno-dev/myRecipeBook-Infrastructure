# IAM Role for App Runner Service (Pulls from ECR)
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

# IAM Role for App Runner Execution (Running App Instances)
resource "aws_iam_role" "app_runner_execution_role" {
  name = "${var.prefix}-AppRunnerExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "tasks.apprunner.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}

# IAM Policy for App Runner Service Role
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
          "ecr:DescribeRepositories"
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

# Attach IAM Policy to App Runner Service Role
resource "aws_iam_role_policy_attachment" "app_runner_policy_attach" {
  role       = aws_iam_role.app_runner_role.name
  policy_arn = aws_iam_policy.app_runner_policy.arn
}

# IAM Policy for App Runner Execution Role
resource "aws_iam_policy" "app_runner_execution_policy" {
  name        = "${var.prefix}-AppRunnerExecutionPolicy"
  description = "IAM policy for App Runner execution role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Allow CloudWatch logs
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      },
      # Allow fetching parameters from SSM
      {
        Effect = "Allow",
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ],
        Resource = "arn:aws:ssm:*:*:parameter/*"
      },
      # Allow Secrets Manager access
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "arn:aws:secretsmanager:*:*:secret:*"
      }
    ]
  })
}

# Attach IAM Policy to Execution Role
resource "aws_iam_role_policy_attachment" "app_runner_execution_policy_attach" {
  role       = aws_iam_role.app_runner_execution_role.name
  policy_arn = aws_iam_policy.app_runner_execution_policy.arn
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