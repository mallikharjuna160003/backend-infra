# DocumentDB Subnet Group
resource "aws_docdb_subnet_group" "docdb_subnet_group" {
  name       = "my-docdb-subnet-group"
  subnet_ids = [
    aws_subnet.mern_app_private_data_subnet_1.id,
    aws_subnet.mern_app_private_data_subnet_2.id,
  ]

  tags = {
    Name = "DocumentDB Subnet Group"
  }
}

# Security Group for DocumentDB
resource "aws_security_group" "docdb_security_group" {
  name        = "docdb-security-group"
  description = "Allow access to DocumentDB"
  vpc_id      = aws_vpc.mern_app_vpc.id  # Ensure this is your desired VPC

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow access from anywhere; restrict as needed
    security_groups = [aws_security_group.mern_data_sg.id]  # Allow access from the app security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Change as needed to restrict outbound access
  }

  tags = {
    Name = "DocumentDB Security Group"
  }
}

# DocumentDB Cluster
resource "aws_docdb_cluster" "my_docdb_cluster" {
  cluster_identifier      = "my-docdb-cluster"
  master_username         = "monster"  # Your preferred username
  master_password         = "SpyderHornes123"  # Your secure password
  skip_final_snapshot     = true  # Set to false for production
  db_subnet_group_name    = aws_docdb_subnet_group.docdb_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.docdb_security_group.id]

  tags = {
    Name = "My DocumentDB Cluster"
  }
}

# DocumentDB Instance
resource "aws_docdb_cluster_instance" "my_docdb_instance" {
  count                = 2  # Adjust this to your desired number of instances
  cluster_identifier   = aws_docdb_cluster.my_docdb_cluster.cluster_identifier
  instance_class       = "db.r5.large"  # Change instance type as needed
  engine               = "docdb"
  availability_zone    = "us-west-2a"  # Ensure this is an available AZ for DocumentDB

  tags = {
    Name = "My DocumentDB Instance ${count.index + 1}"
  }
}

# Output the DocumentDB Endpoint
output "documentdb_endpoint" {
  value = aws_docdb_cluster.my_docdb_cluster.endpoint
}
