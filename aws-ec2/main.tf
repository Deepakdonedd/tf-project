terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

#create a VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "MyVpc"
  }  
}

#public subnet
resource "aws_subnet" "public_subnet_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true 

  tags = {
    Name = "PublicSubnet1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true 

  tags = {
    Name = "PublicSubnet2"
  }
}

#private-subnet
resource "aws_subnet" "private_subnet_1" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "PrivateSubnet1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id = aws_vpc.my_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "ap-south-1b"
  
  tags = {
    Name = "PrivateSubnet2"
  }
}

#internet gateway
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "MyIgw"
  } 
}

#route table for public subnet
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "PublicRouteTable"
}
}

resource "aws_route_table_association" "public_rt_association_1" {
  subnet_id = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_rt_association_2" {
  subnet_id = aws_subnet.public_subnet_2.id 
  route_table_id = aws_route_table.public_rt.id
}

#Nat gateway for private subnet
resource "aws_eip" "my_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "my_ngw" {
  allocation_id = aws_eip.my_eip.id
  subnet_id = aws_subnet.public_subnet_1.id

  tags = {
    Name = "MyNatGateway"
  }
}

#route table for private subnet
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.my_ngw.id
  }

  tags = {
    Name = "PrivateRouteTable"
  }
}
#Associate private route table with private subnet
resource "aws_route_table_association" "private_rt_association_1" {
  subnet_id = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_rt_association_2" {
  subnet_id = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

#security group
resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

#ssh access
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #http access
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  #outbound access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MySecurityGroup"
  }
}

#ec2 instance
resource "aws_instance" "app_machine" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.my_sg.id]
  key_name = var.existing_key_pair

  tags = {
    Name = "AppMachine"
  }
}

resource "aws_instance" "tools_machine" {
  ami           = "ami-00bb6a80f01f03502"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet_2.id
  security_groups = [aws_security_group.my_sg.id]
  key_name = var.existing_key_pair

  tags = {
    Name = "ToolsMachine"
  }
}