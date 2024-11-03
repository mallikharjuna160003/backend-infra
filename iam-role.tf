# IAM Role
resource "aws_iam_role" "secrets_ecr_cloudwatch_role" {
  name               = "SecretsECRCloudWatchRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"  # lambda.amazonaws.com # This specifies that the role can be assumed by AWS Lambda
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


# IAM Policy for Secrets Manager and ECR
resource "aws_iam_policy" "secrets_ecr_cloudwatch_policy" {
  name        = "read-SecretsECRCloudWatchPolicy"
  description = "Policy to allow access to Secrets Manager, ECR, and CloudWatch"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.documentdb_secret.arn # Use the ARN of your specific secret
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetAuthorizationToken",
          "ecr:DescribeRepositories"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:SetAlarmState"
        ]
        Resource = "*"
      }
    ]
  })
}


# Attach Policy to Role
resource "aws_iam_role_policy_attachment" "attach_secrets_ecr_cloudwatch_policy" {
  policy_arn = aws_iam_policy.secrets_ecr_cloudwatch_policy.arn
  role       = aws_iam_role.secrets_ecr_cloudwatch_role.name
}

# Attach ECS Task Execution Role Policy
resource "aws_iam_role_policy_attachment" "attach_ecs_task_execution_role_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  role       = aws_iam_role.secrets_ecr_cloudwatch_role.name
}
