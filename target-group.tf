# Define the VPC and Subnets (replace these with your existing definitions)

# Create Target Group
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-target-group"
  port     = 5000  # Change to your application's port
  protocol = "HTTP"  # Change to HTTPS if needed
  vpc_id   = aws_vpc.mern_app_vpc.id

  health_check {
    path                = "/health"  # Update to your health check endpoint
    interval            = 30
    timeout             = 10
    healthy_threshold  = 2
    unhealthy_threshold = 5
    # success_codes = "200"
  }

  tags = {
    Name = "App Target Group"
  }
   # Set the target type to ip
  target_type = "ip"  # Set this to "ip" for Fargate
}

/*
# Example of adding instances (IP addresses) to the Target Group
resource "aws_lb_target_group_attachment" "app_target_group_attachment" {
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = "10.0.2.10"  # Replace with your instance's private IP
  port             = 80  # Same as target group port
}
*/

# (Optional) Create an ALB to direct traffic to the target group
resource "aws_lb" "app_lb" {
  name               = "app-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mern_lb_sg.id]
  subnets            = [aws_subnet.mern_app_public_subnet_1.id,aws_subnet.mern_app_public_subnet_2.id]
  #vpc_id   = aws_vpc.mern_app_vpc.id
  enable_deletion_protection = false

  tags = {
    Name = "App Load Balancer"
  }
}
# Listener for the Load Balancer
resource "aws_lb_listener" "app_listener" {
  load_balancer_arn = aws_lb.app_lb.arn
  port              = 80  # Change to 443 for HTTPS
  protocol          = "HTTP"  # Change to HTTPS if needed

  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
