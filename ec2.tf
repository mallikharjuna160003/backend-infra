# EC2 Instance
resource "aws_instance" "mern_app_instance" {
  ami                    = "ami-07c5ecd8498c59db5"  # Replace with the latest AMI ID for your region
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.mern_app_public_subnet_1.id  # Use the public subnet
  vpc_security_group_ids = [aws_vpc.mern_app_vpc.default_security_group_id]  # Reference the default security group
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "mern-app-instance"
  }
}

