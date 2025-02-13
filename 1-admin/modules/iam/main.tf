# Create Policies for the resource creator
resource "aws_iam_policy" "vpc_policy" {
  name        = "${var.prefix}-VPCPolicy"
  description = "IAM policy for managing VPC resources"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateVpc",
          "ec2:DescribeVpcs",
          "ec2:ModifyVpcAttribute",
          "ec2:DeleteVpc",
          "ec2:CreateSubnet",
          "ec2:ModifySubnetAttribute",
          "ec2:DescribeSubnets",
          "ec2:DeleteSubnet",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:AssociateRouteTable",
          "ec2:DescribeRouteTables",
          "ec2:DeleteRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:DescribeSecurityGroups",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:DeleteSecurityGroup",
          "ec2:DescribeAvailabilityZones",
          "ec2:CreateTags",
          "ec2:DeleteTags",
          "ec2:DescribeVpcAttribute",
          "ec2:ModifyVpcAttribute",
          "ec2:DescribeInternetGateways",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DetachInternetGateway",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:CreateRoute",
          "ec2:DisassociateRouteTable"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "s3_policy" {
  name        = "${var.prefix}-S3Policy"
  description = "IAM policy for managing S3"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "GlobalBucketListing",
        "Effect": "Allow",
        "Action": "s3:ListAllMyBuckets",
        "Resource": "*"
      },
      {
        "Sid": "FullBucketControl",
        "Effect": "Allow",
        "Action": "s3:*",
        "Resource": [
          "arn:aws:s3:::${var.prefix}-s3-bucket",
          "arn:aws:s3:::${var.prefix}-s3-bucket/*"
        ]
      }
    ]
  })
}
resource "aws_iam_policy" "s3_policy_terraform" {
  name        = "${var.prefix}-S3TerraformPolicy"
  description = "IAM policy for managing S3 terraform backend"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        "Effect": "Allow",
        "Action": [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ],
        "Resource": "arn:aws:s3:::${var.prefix}-terraform-state-unique1029"
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ],
        "Resource": "arn:aws:s3:::${var.prefix}-terraform-state-unique1029/*"
      }
    ]
  })
}
resource "aws_iam_policy" "sqs_policy" {
  name        = "${var.prefix}-SQSPolicy"
  description = "IAM policy for managing SQS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ListQueues",
          "sqs:ListQueueTags"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "rds_policy" {
  name        = "${var.prefix}-RDSPolicy"
  description = "IAM policy for managing RDS"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "rds:DescribeDBInstances",
          "rds:CreateDBInstance",
          "rds:ModifyDBInstance",
          "rds:DeleteDBInstance",
          "rds:DescribeDBSecurityGroups",
          "rds:DescribeDBSubnetGroups",
          "rds:CreateDBSubnetGroup",
          "rds:ModifyDBSubnetGroup",
          "rds:AddTagsToResource",
          "rds:ListTagsForResource",
          "rds:DeleteDBSubnetGroup"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "ecr_policy" {
  name        = "${var.prefix}-ECRPolicy"
  description = "IAM policy for managing Amazon ECR"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          # Standard repository and authentication actions
          "ecr:CreateRepository",
          "ecr:DeleteRepository",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories",
          "ecr:GetRepositoryPolicy",
          "ecr:SetRepositoryPolicy",
          "ecr:DeleteRepositoryPolicy",

          # Image-related actions
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:ListImages",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:DescribeImages",

          # Image scanning actions
          "ecr:StartImageScan",
          "ecr:DescribeImageScanFindings",
          "ecr:PutImageScanningConfiguration",

          # Layer upload actions
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",

          # Lifecycle policies
          "ecr:PutLifecyclePolicy",
          "ecr:GetLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy",

          # Logging & monitoring
          "logs:CreateLogStream",
          "logs:PutLogEvents",

          # Registry-level permissions
          "ecr:GetRegistryPolicy",
          "ecr:PutRegistryPolicy",
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "app_runner_policy" {
  name        = "${var.prefix}-AppRunnerPolicy"
  description = "IAM policy for managing AWS App Runner"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "apprunner:CreateService",
          "apprunner:DescribeService",
          "apprunner:UpdateService",
          "apprunner:DeleteService",
          "apprunner:ListServices",
          "apprunner:TagResource",
          "apprunner:ListTagsForResource"
        ],
        Resource = "*"
      }
    ]
  })
}
resource "aws_iam_policy" "iam_policy" {
  name        = "${var.prefix}-IAMPolicy"
  description = "IAM policy for managing IAM Roles and Policies"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:ListRoles",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole",
          "iam:PassRole",
          "iam:GetInstanceProfile",
          "iam:CreateInstanceProfile",
          "iam:DeleteInstanceProfile",
          "iam:AddRoleToInstanceProfile",
          "iam:RemoveRoleFromInstanceProfile"
        ],
        Resource = "arn:aws:iam::533267083060:role/${var.prefix}-*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicies",
          "iam:ListPolicyVersions"
        ],
        Resource = "arn:aws:iam::533267083060:policy/${var.prefix}-*"
      }
    ]
  })
}
# Create IAM Group for the resource creator
resource "aws_iam_group" "user_group" {
  name = "${var.prefix}-group"
}

# Attach policies to the Group for the resource creator
resource "aws_iam_group_policy_attachment" "attach_vpc" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.vpc_policy.arn
}
resource "aws_iam_group_policy_attachment" "attach_s3" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.s3_policy.arn
}
resource "aws_iam_group_policy_attachment" "attach_s3_terraform_backend" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.s3_policy_terraform.arn
}
resource "aws_iam_group_policy_attachment" "attach_sqs" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.sqs_policy.arn
}
resource "aws_iam_group_policy_attachment" "attach_rds" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.rds_policy.arn
}
resource "aws_iam_group_policy_attachment" "attach_ecr" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.ecr_policy.arn
}
resource "aws_iam_group_policy_attachment" "attach_app_runner" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.app_runner_policy.arn
}
resource "aws_iam_group_policy_attachment" "attach_iam" {
  group      = aws_iam_group.user_group.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

# Add the resources_creator to the group
resource "aws_iam_user_group_membership" "add_user_to_group" {
  user  = var.resources_creator_profile
  groups = [aws_iam_group.user_group.name]
}