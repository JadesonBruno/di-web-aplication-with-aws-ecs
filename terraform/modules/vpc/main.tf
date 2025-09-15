# Data source for available AWS availability zones
data "aws_availability_zones" "available" {
  state = "available"
}


# VPC Resource
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "${var.project_name}-${var.environment}-vpc"
    Project = var.project_name
    Environment = var.environment
    Service = "airbyte"
    Terraform = "true"
  }
}


# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-igw"
    Project = var.project_name
    Environment = var.environment
    Service = "airbyte"
    Terraform = "true"
  }
}


# Public Subnets 
resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.main.id
  cidr_block = "10.1.${count.index}.0/24" # 10.1.0.0/24, 10.1.1.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-${var.environment}-public-${substr(data.aws_availability_zones.available.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Type = "public"
    Terraform = "true"
  }
}


# Private Subnets
resource "aws_subnet" "private" {
  count = 2

  vpc_id = aws_vpc.main.id
  cidr_block = "10.1.${2 + count.index}.0/24" # 10.1.2.0/24, 10.1.3.0/24
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${var.environment}-private-${substr(data.aws_availability_zones.available.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Service = "private"
    Terraform = "true"
  }
}


# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = length(aws_subnet.public)

  domain = "vpc"

  tags = {
    Name = "${var.project_name}-${var.environment}-eip-nat-${substr(data.aws_availability_zones.available.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Terraform = "true"
  }
}


# NAT Gateways
resource "aws_nat_gateway" "main" {
  count = length(aws_subnet.public)
    
  allocation_id = aws_eip.nat[count.index].id
  subnet_id = aws_subnet.public[count.index].id
  connectivity_type = "public"
  
  tags = {
      Name = "${var.project_name}-${var.environment}-nat-gw-${substr(data.aws_availability_zones.available.names[count.index], -2, 2)}"
      Project = var.project_name
      Environment = var.environment
      Terraform = "true"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  count = length(aws_subnet.public)

  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-public-rt-${substr(data.aws_availability_zones.available.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Type = "public"
    Terraform = "true"
  }
}


# Private Route Table
resource "aws_route_table" "private" {
  count = length(aws_subnet.private)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main[count.index].id
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-private-rt-${substr(data.aws_availability_zones.available.names[count.index], -2, 2)}"
    Project = var.project_name
    Environment = var.environment
    Type = "private"
    Terraform = "true"
  }
}


resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public)

  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}


resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
