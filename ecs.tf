# ECS Cluster
resource "aws_ecs_cluster" "my_ecs_cluster" {
  name = "my-ecs-cluster"
  
  # Enable the Fargate capacity provider
  #capacity_providers = ["FARGATE"]

  tags = {
    Namespace = "your-namespace"  # Replace with your desired namespace
  }
}

# Fargate Service Definition (optional)
resource "aws_ecs_service" "my_ecs_service" {
  name            = "my-ecs-service"
  cluster         = aws_ecs_cluster.my_ecs_cluster.id
  task_definition = aws_ecs_task_definition.mern_chat_app.arn  # Reference to your task definition
  desired_count   = 1
  launch_type     = "FARGATE"
  
  network_configuration {
    subnets          = [aws_subnet.mern_app_private_app_subnet_1.id, aws_subnet.mern_app_private_app_subnet_2.id]
    security_groups  = [aws_security_group.mern_app_sg.id]
    assign_public_ip = false   # Set to "DISABLED" to turn off public IP assignment
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.app_target_group.arn #aws_lb_target_group.mern_app_target_group.arn
    container_name   = "mern-chat-app-backend"  # Match the container name in your task definition
    container_port   = 5000  # Match the container port
  }

  tags = {
    Namespace = "your-namespace"  # Replace with your desired namespace
  }
  depends_on = [aws_lb_listener.app_listener]  # Ensure ALB listener is created before ECS service
}

resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/ecs/mern-chat-app-backend"
}


#---------------------Auto Scaling ------------------------

resource "aws_appautoscaling_target" "ecs_service_scaling_target" {
  max_capacity       = 2                             # Maximum number of tasks
  min_capacity       = 1                             # Minimum number of tasks
  resource_id        = "service/${aws_ecs_cluster.my_ecs_cluster.name}/${aws_ecs_service.my_ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_service_scale_up" {
  name               = "ecs-scale-up-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value       = 70.0                         # Target CPU utilization percentage
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    scale_in_cooldown  = 300                          # Time (in seconds) before another scale-in action can be triggered
    scale_out_cooldown = 300                          # Time (in seconds) before another scale-out action can be triggered
  }
}

resource "aws_appautoscaling_policy" "ecs_service_scale_down" {
  name               = "ecs-scale-down-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_scaling_target.resource_id
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"

  target_tracking_scaling_policy_configuration {
    target_value       = 75.0                         # Target memory utilization percentage
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
  }
}

