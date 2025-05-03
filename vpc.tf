#Create vpc for to use in EKS
resource "aws_vpc" "eks_vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "${var.cluster_name}-vpc"
  }
}

#Create public subnet a
resource "aws_subnet" "public_subnet_a" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-subnet-public"
    "kubernetes.io/role/elb" = "1"
  }
}

#Create public subnet b
resource "aws_subnet" "public_subnet_b" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.region}b"
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.cluster_name}-subnet-public"
    "kubernetes.io/role/elb" = "1"
  }
}

#Create private subnet a
resource "aws_subnet" "private_subnet_a" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "${var.region}a"

  tags = {
    Name = "${var.cluster_name}-subnet-private"
    "kubernetes.io/role/elb" = "1"
  }
}

#Create private subnet b
resource "aws_subnet" "private_subnet_b" {
  vpc_id     = aws_vpc.eks_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "${var.cluster_name}-subnet-private"
    "kubernetes.io/role/elb" = "1"
  }
}

#Create Internet Gateway for public subnet
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "${var.cluster_name}-igw"
  }
}

#Create EIP for NAT gateway
resource "aws_eip" "eks_eip" {
  domain   = "vpc"
  depends_on = [ aws_internet_gateway.eks_igw ]
}

#Create NAT gateway
resource "aws_nat_gateway" "eks_nat_gw" {
  allocation_id = aws_eip.eks_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id

  tags = {
    Name = "${var.cluster_name}-nat-gw"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.eks_igw]
}


#Create route table for public subnet to IGW
resource "aws_route_table" "eks_public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "${var.cluster_name}-public-rt"
  }
}

#Create route table for private subnet to NAT GW
resource "aws_route_table" "eks_private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.eks_nat_gw.id
  }

  tags = {
    Name = "${var.cluster_name}-private-rt"
  }
}

#Create subnet association with route table for public 1a
resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.eks_public_rt.id
}

#Create subnet association with route table public 1b
resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.eks_public_rt.id
}

#Create subnet association with route table for private 1a
resource "aws_route_table_association" "private_1a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.eks_private_rt.id
}

#Create subnet association with route table for private 1b
resource "aws_route_table_association" "private_1b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.eks_private_rt.id
}