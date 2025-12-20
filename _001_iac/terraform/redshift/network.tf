####################
## Network - Main ##
####################

# AWS Availability Zones data
data "aws_availability_zones" "available" {}

######################################

# Create the VPC
resource "aws_vpc" "redshift-serverless-vpc" {
  cidr_block           = var.redshift_serverless_vpc_cidr
  enable_dns_hostnames = true
  
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-redshift-serverless-vpc"
    Environment = var.app_environment
  }
}

######################################

# Create the Redshift Subnet AZ1
resource "aws_subnet" "redshift-serverless-subnet-az1" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = var.redshift_serverless_subnet_1_cidr
  availability_zone = data.aws_availability_zones.available.names[0]
  
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-redshift-serverless-subnet-az1"
    Environment = var.app_environment
  }
}

# Create the Redshift Subnet AZ2
resource "aws_subnet" "redshift-serverless-subnet-az2" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = var.redshift_serverless_subnet_2_cidr
  availability_zone = data.aws_availability_zones.available.names[1]
  
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-redshift-serverless-subnet-az2"
    Environment = var.app_environment
  }
}

# Create the Redshift Subnet AZ3
resource "aws_subnet" "redshift-serverless-subnet-az3" {
  vpc_id            = aws_vpc.redshift-serverless-vpc.id
  cidr_block        = var.redshift_serverless_subnet_3_cidr
  availability_zone = data.aws_availability_zones.available.names[2]
  
  tags = {
    Name        = "${var.app_name}-${var.app_environment}-redshift-serverless-subnet-az3"
    Environment = var.app_environment
  }
}

######################################

# Create Internet Gateway (required for publicly_accessible = true)
resource "aws_internet_gateway" "redshift-serverless-igw" {
  vpc_id = aws_vpc.redshift-serverless-vpc.id

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-redshift-serverless-igw"
    Environment = var.app_environment
  }
}

######################################

# Create Route Table for public subnets
resource "aws_route_table" "redshift-serverless-rt" {
  vpc_id = aws_vpc.redshift-serverless-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.redshift-serverless-igw.id
  }

  tags = {
    Name        = "${var.app_name}-${var.app_environment}-redshift-serverless-rt"
    Environment = var.app_environment
  }
}

######################################

# Associate Route Table with Subnet AZ1
resource "aws_route_table_association" "redshift-serverless-rta-az1" {
  subnet_id      = aws_subnet.redshift-serverless-subnet-az1.id
  route_table_id = aws_route_table.redshift-serverless-rt.id
}

# Associate Route Table with Subnet AZ2
resource "aws_route_table_association" "redshift-serverless-rta-az2" {
  subnet_id      = aws_subnet.redshift-serverless-subnet-az2.id
  route_table_id = aws_route_table.redshift-serverless-rt.id
}

# Associate Route Table with Subnet AZ3
resource "aws_route_table_association" "redshift-serverless-rta-az3" {
  subnet_id      = aws_subnet.redshift-serverless-subnet-az3.id
  route_table_id = aws_route_table.redshift-serverless-rt.id
}

