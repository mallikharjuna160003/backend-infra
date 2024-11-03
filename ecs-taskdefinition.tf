resource "aws_ecs_task_definition" "mern_chat_app" {
  family                   = "mern-chat-app"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  memory                   = "4096"  # Adjust as necessary
  cpu                      = "2048"  # Adjust as necessary
  execution_role_arn       = aws_iam_role.secrets_ecr_cloudwatch_role.arn  # Role for pulling images
  task_role_arn            = aws_iam_role.secrets_ecr_cloudwatch_role.arn  # Role for accessing Secrets Manager

  container_definitions = jsonencode([
    {
      name      = "mern-chat-app-backend"
      image     = "a6j0n/mern-chat-app-backend:latest"  # Update with your ECR image URI
      cpu       = 1024
      memory    = 1024
      essential = true

      environment = [
        {
          name  = "DOCDB_ENDPOINT"
          value = aws_docdb_cluster.my_docdb_cluster.endpoint  # Replace with your actual DocumentDB endpoint
        },
        {
          name  = "CERT_PATH"
          value = "/usr/local/share/ca-certificates/global-bundle.pem"
        },
        {
	    name  = "SECRET_NAME"
	    value = aws_secretsmanager_secret.documentdb_secret.name  # Reference the name of the Secrets Manager secret
        },
	{
          name  = "DB_DATABASE"
          value = "ChatAPP"  # Replace with your database name
        },
        {
          name  = "JWT_SECRET"
          value = "piyush"  # Replace with your database name
        },
        {
          name  = "PORT"
          value = "5000"  # Replace with your database name
        },
        {
          name  = "AWS_REGION"
          value = var.region   # Replace with your database name
        }
      ]

      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
          protocol      = "tcp"
        }
      ]

      # Define the user to run the application as a non-root user
      #user = "nodeuser"  # This should match the non-root user created in your Dockerfile
     # Configure health check
      healthCheck = {
        command     = ["CMD-SHELL", "curl -f http://localhost:5000 || exit 1"]
        interval    = 30          # Interval in seconds between health checks
        timeout     = 5           # Timeout in seconds for each health check
        retries     = 3           # Number of retries before marking the container as unhealthy
        startPeriod = 60          # Grace period after the container starts before starting health checks
      }

      # Configure logging to CloudWatch
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/mern-chat-app-backend"  # Log group name
          "awslogs-region"        = var.region                      # AWS region
          "awslogs-stream-prefix" = "ecs"                          # Log stream prefix
        }
      }
    }
  ])
}

