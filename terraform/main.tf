terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Data source to get latest Ubuntu 20.04 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical (Ubuntu)

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Generate SSH Key Pair using TLS provider
resource "tls_private_key" "terraform_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create AWS Key Pair from generated public key
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key-${var.project_name}"
  public_key = tls_private_key.terraform_key.public_key_openssh

  tags = {
    Name    = "terraform-key-${var.project_name}"
    Project = var.project_name
  }
}

# Save private key locally (as required by assignment)
resource "local_file" "private_key" {
  content         = tls_private_key.terraform_key.private_key_pem
  filename        = "${path.module}/terraform-key.pem"
  file_permission = "0400"
}

# Security Group with all required ports
resource "aws_security_group" "devops_sg" {
  name        = "${var.project_name}-sg"
  description = "Security group for DevOps assignment - allows SSH, HTTP, HTTPS, and Docker Swarm ports"

  # SSH Access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP Access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS Access
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Django Application Port
  ingress {
    description = "Django App"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PostgreSQL (for testing)
  ingress {
    description = "PostgreSQL"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Swarm - Manager/Worker Communication (TCP)
  ingress {
    description = "Docker Swarm Management"
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Swarm - Node Communication (TCP)
  ingress {
    description = "Docker Swarm Node Communication TCP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Swarm - Node Communication (UDP)
  ingress {
    description = "Docker Swarm Node Communication UDP"
    from_port   = 7946
    to_port     = 7946
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker Swarm - Overlay Network (UDP)
  ingress {
    description = "Docker Swarm Overlay Network"
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound - Allow all
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.project_name}-sg"
    Project = var.project_name
  }
}

# EC2 Instance - Swarm Manager
resource "aws_instance" "swarm_manager" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name    = "swarm-manager"
    Role    = "manager"
    Project = var.project_name
  }

  # User data to set hostname
  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname swarm-manager
              EOF
}

# Elastic IP for Swarm Manager
resource "aws_eip" "manager_eip" {
  instance = aws_instance.swarm_manager.id
  domain   = "vpc"

  tags = {
    Name    = "manager-eip"
    Project = var.project_name
  }

  depends_on = [aws_instance.swarm_manager]
}

# EC2 Instance - Swarm Worker A
resource "aws_instance" "swarm_worker_a" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name    = "swarm-worker-a"
    Role    = "worker"
    Project = var.project_name
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname swarm-worker-a
              EOF
}

# Elastic IP for Worker A
resource "aws_eip" "worker_a_eip" {
  instance = aws_instance.swarm_worker_a.id
  domain   = "vpc"

  tags = {
    Name    = "worker-a-eip"
    Project = var.project_name
  }

  depends_on = [aws_instance.swarm_worker_a]
}

# EC2 Instance - Swarm Worker B
resource "aws_instance" "swarm_worker_b" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.devops_sg.id]

  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name    = "swarm-worker-b"
    Role    = "worker"
    Project = var.project_name
  }

  user_data = <<-EOF
              #!/bin/bash
              hostnamectl set-hostname swarm-worker-b
              EOF
}

# Elastic IP for Worker B
resource "aws_eip" "worker_b_eip" {
  instance = aws_instance.swarm_worker_b.id
  domain   = "vpc"

  tags = {
    Name    = "worker-b-eip"
    Project = var.project_name
  }

  depends_on = [aws_instance.swarm_worker_b]
}
