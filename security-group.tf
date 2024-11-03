resource "aws_security_group" "mern_app_sg" {
  vpc_id = aws_vpc.mern_app_vpc.id

  name        = "mern-app-sg"
  description = "Security group for MERN application"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["10.0.3.0/24", "10.0.4.0/24"]  # Allow traffic from app subnets
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.mern_lb_sg.id]  # Allow traffic from the load balancer
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    security_groups = [aws_security_group.mern_lb_sg.id]  # Allow traffic from the load balancer
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mern-app-sg"
  }
}

resource "aws_security_group" "mern_data_sg" {
  vpc_id = aws_vpc.mern_app_vpc.id

  name        = "mern-data-sg"
  description = "Security group for MERN data"

  ingress {
    from_port   = 27017  # Change to your database port if different
    to_port     = 27017
    protocol    = "tcp"
    security_groups = [aws_security_group.mern_app_sg.id]  # Allow traffic from app security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mern-data-sg"
  }
}

# Example Load Balancer Security Group (if applicable)
resource "aws_security_group" "mern_lb_sg" {
  vpc_id = aws_vpc.mern_app_vpc.id

  name        = "mern-lb-sg"
  description = "Security group for MERN Load Balancer"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTP traffic from anywhere
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mern-lb-sg"
  }
}
