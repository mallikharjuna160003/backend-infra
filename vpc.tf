provider "aws" {
  region = "us-west-2"  # Change this to your desired region
}

# VPC Configuration
resource "aws_vpc" "mern_app_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "mern-app-vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "mern_app_igw" {
  vpc_id = aws_vpc.mern_app_vpc.id

  tags = {
    Name = "mern-app-igw"
  }
}

# NAT Gateway
resource "aws_eip" "mern_nat_eip" {
  # 'vpc' argument is deprecated, use 'domain' instead
  domain = "vpc"
}

resource "aws_nat_gateway" "mern_nat_gateway" {
  allocation_id = aws_eip.mern_nat_eip.id
  subnet_id    = aws_subnet.mern_app_public_subnet_1.id

  tags = {
    Name = "mern-app-nat-gateway"
  }
}

# Public Subnets
resource "aws_subnet" "mern_app_public_subnet_1" {
  vpc_id            = aws_vpc.mern_app_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"  # Change as necessary

  tags = {
    Name = "mern-app-public-subnet-1"
  }
}

resource "aws_subnet" "mern_app_public_subnet_2" {
  vpc_id            = aws_vpc.mern_app_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"  # Change as necessary

  tags = {
    Name = "mern-app-public-subnet-2"
  }
}

# Private Subnets for Application
resource "aws_subnet" "mern_app_private_app_subnet_1" {
  vpc_id            = aws_vpc.mern_app_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-west-2a"  # Change as necessary

  tags = {
    Name = "mern-app-private-app-subnet-1"
  }
}

resource "aws_subnet" "mern_app_private_app_subnet_2" {
  vpc_id            = aws_vpc.mern_app_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-west-2b"  # Change as necessary

  tags = {
    Name = "mern-app-private-app-subnet-2"
  }
}

# Private Subnets for Data
resource "aws_subnet" "mern_app_private_data_subnet_1" {
  vpc_id            = aws_vpc.mern_app_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "us-west-2a"  # Change as necessary

  tags = {
    Name = "mern-app-private-data-subnet-1"
  }
}

resource "aws_subnet" "mern_app_private_data_subnet_2" {
  vpc_id            = aws_vpc.mern_app_vpc.id
  cidr_block        = "10.0.6.0/24"
  availability_zone = "us-west-2b"  # Change as necessary

  tags = {
    Name = "mern-app-private-data-subnet-2"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "mern_app_public_rt" {
  vpc_id = aws_vpc.mern_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mern_app_igw.id
  }

  tags = {
    Name = "mern-app-public-rt"
  }
}

# Private Route Table for Application Subnet 1
resource "aws_route_table" "mern_app_private_app_subnet_1_rt" {
  vpc_id = aws_vpc.mern_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mern_nat_gateway.id
  }

  tags = {
    Name = "mern-app-private-app-subnet-1-rt"
  }
}

# Private Route Table for Application Subnet 2
resource "aws_route_table" "mern_app_private_app_subnet_2_rt" {
  vpc_id = aws_vpc.mern_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mern_nat_gateway.id
  }

  tags = {
    Name = "mern-app-private-app-subnet-2-rt"
  }
}

# Private Route Table for Data Subnet 1
resource "aws_route_table" "mern_app_private_data_subnet_1_rt" {
  vpc_id = aws_vpc.mern_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mern_nat_gateway.id
  }

  tags = {
    Name = "mern-app-private-data-subnet-1-rt"
  }
}

# Private Route Table for Data Subnet 2
resource "aws_route_table" "mern_app_private_data_subnet_2_rt" {
  vpc_id = aws_vpc.mern_app_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.mern_nat_gateway.id
  }

  tags = {
    Name = "mern-app-private-data-subnet-2-rt"
  }
}

# Associating Public Subnets with the Public Route Table
resource "aws_route_table_association" "mern_app_public_subnet_1_association" {
  subnet_id      = aws_subnet.mern_app_public_subnet_1.id
  route_table_id = aws_route_table.mern_app_public_rt.id
}

resource "aws_route_table_association" "mern_app_public_subnet_2_association" {
  subnet_id      = aws_subnet.mern_app_public_subnet_2.id
  route_table_id = aws_route_table.mern_app_public_rt.id
}

# Associating Application Subnet 1 with its Private Route Table
resource "aws_route_table_association" "mern_app_private_app_subnet_1_association" {
  subnet_id      = aws_subnet.mern_app_private_app_subnet_1.id
  route_table_id = aws_route_table.mern_app_private_app_subnet_1_rt.id
}

# Associating Application Subnet 2 with its Private Route Table
resource "aws_route_table_association" "mern_app_private_app_subnet_2_association" {
  subnet_id      = aws_subnet.mern_app_private_app_subnet_2.id
  route_table_id = aws_route_table.mern_app_private_app_subnet_2_rt.id
}

# Associating Data Subnet 1 with its Private Route Table
resource "aws_route_table_association" "mern_app_private_data_subnet_1_association" {
  subnet_id      = aws_subnet.mern_app_private_data_subnet_1.id
  route_table_id = aws_route_table.mern_app_private_data_subnet_1_rt.id
}

# Associating Data Subnet 2 with its Private Route Table
resource "aws_route_table_association" "mern_app_private_data_subnet_2_association" {
  subnet_id      = aws_subnet.mern_app_private_data_subnet_2.id
  route_table_id = aws_route_table.mern_app_private_data_subnet_2_rt.id
}

