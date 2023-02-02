terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
}


/*************************************
*                                    *
*  INSTANCE SETUP                    *
*                                    *
**************************************/


resource "aws_instance" "app_server" {
  ami           = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.xks_subnet.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.xks_secgroup.id]
  key_name = var.key_name
  tags = {
    Name = "${var.name}-instance"
  }

  root_block_device {
    volume_type           = "gp2"
    volume_size           = var.root_block_device_size
    delete_on_termination = "true"
  }

// TODO  user_data = 

}


/*************************************
*                                    *
*  NETWORK                           *
*                                    *
**************************************/

resource "aws_vpc" "xks_vpc" {
  cidr_block = var.network_address_space

  tags = {
    Name = "${var.name}-VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.xks_vpc.id
  tags = {
    Name = "${var.name}-IGW"
  }
}

resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.xks_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.name}-IGW-rtb"
  }
}

resource "aws_route_table_association" "xks-rtb" {
  subnet_id      = aws_subnet.xks_subnet.id
  route_table_id = aws_route_table.rtb.id
}


resource "aws_subnet" "xks_subnet" {
  vpc_id                  = aws_vpc.xks_vpc.id
  cidr_block              = var.network_address_space
  map_public_ip_on_launch = "true"
  tags = {
    Name = "${var.name}-subnet"
  }
}

/*************************************
*                                    *
*  SECURITY GROUPS                   *
*                                    *
**************************************/


resource "aws_security_group" "xks-secgroup" {
  name        = "${var.name}-primary-sg"
  description = "Primary ASG"
  vpc_id      = aws_vpc.xks_vpc.id
}

resource "aws_security_group_rule" "ssh" {
  security_group_id = aws_security_group.xks-secgroup.id
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = [var.whitelist_ip]
}

resource "aws_security_group_rule" "http" {
  security_group_id = aws_security_group.xks-secgroup.id
  type              = "ingress"
  from_port         = 8000
  to_port           = 8000
  protocol          = "tcp"
  cidr_blocks       = [var.whitelist_ip]
}

resource "aws_security_group_rule" "https" {
  security_group_id = aws_security_group.xks-secgroup.id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.whitelist_ip]
}