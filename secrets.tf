# Define the S3 bucket for storing the Lambda function
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "your-unique-s3-bucket-name"  # Use a globally unique bucket name
  #acl    = "private"                       # You can comment or remove this line
}

# Upload the Lambda function ZIP file to S3 using the new resource
resource "aws_s3_object" "lambda_function" {
  bucket = aws_s3_bucket.lambda_bucket.id
  key    = "lambda_function.zip"           # The name it will have in S3
  source = "lambda_function.zip"            # Path to your local ZIP file
}

# Define the assume role policy for the Lambda function
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Create the DocumentDB secret
resource "aws_secretsmanager_secret" "documentdb_secret" {
  name        = "my_documentdb_secret"
  description = "Credentials for DocumentDB"

  tags = {
    Name = "DocumentDB Secret"
  }
}


resource "aws_secretsmanager_secret_version" "documentdb_secret_version" {
  secret_id     = aws_secretsmanager_secret.documentdb_secret.id
  secret_string = jsonencode({
    username = aws_docdb_cluster.my_docdb_cluster.master_username
    password = aws_docdb_cluster.my_docdb_cluster.master_password
  })
}



# Create the Lambda function for rotation
resource "aws_lambda_function" "rotation_lambda" {
  function_name = "documentdb_rotation_lambda"
  runtime       = "python3.8"  # Adjust as needed
  handler       = "index.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  s3_bucket     = aws_s3_bucket.lambda_bucket.id
  s3_key        = aws_s3_object.lambda_function.key
  timeout       = 30

  # Define the environment variables block
  environment {
    variables = {
      SECRET_ARN = aws_secretsmanager_secret.documentdb_secret.arn
    }
  }
}

# Attach the IAM role to the Lambda function
resource "aws_iam_role" "lambda_role" {
  name               = "documentdb_rotation_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# IAM Policy for the Lambda to access Secrets Manager and DocumentDB
resource "aws_iam_policy" "lambda_policy" {
  name        = "documentdb_rotation_lambda_policy"
  description = "Policy for DocumentDB rotation Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:DeleteSecret",
          "secretsmanager:RotateSecret"
        ]
        Resource = aws_secretsmanager_secret.documentdb_secret.arn
      },
      {
        Effect = "Allow"
        Action = [
          "docdb:DescribeDBClusters",
          "docdb:ModifyDBCluster",
          "docdb:DescribeDBInstances",
          "docdb:ModifyDBInstance",
          "docdb:ListTagsForResource",
          "docdb:AddTagsToResource",
          "docdb:RemoveTagsFromResource"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Grant Secrets Manager permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_secrets_manager" {
  statement_id  = "AllowExecutionFromSecretsManager"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.rotation_lambda.function_name
  principal     = "secretsmanager.amazonaws.com"
}

# Enable automatic rotation for the secret
resource "aws_secretsmanager_secret_rotation" "documentdb_secret_rotation" {
  secret_id              = aws_secretsmanager_secret.documentdb_secret.id
  rotation_lambda_arn     = aws_lambda_function.rotation_lambda.arn
  rotation_rules {
    automatically_after_days = 30  # Adjust as needed
  }
}

