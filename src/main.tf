terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name                    = "task-6-2-vpc"
  cidr                    = "10.0.0.0/20"
  azs                     = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnets         = ["10.0.1.0/24"]
  public_subnets          = ["10.0.0.0/24"]
  enable_nat_gateway      = true
  single_nat_gateway      = true
  map_public_ip_on_launch = true
}

resource "aws_security_group" "allow-ssh" {
  name        = "allow-ssh"
  description = "allow-ssh"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "allow 22"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "allow all"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "ssh_key_name" {
  description = "Your SSH key name"
  type        = string
  default     = "terraform"
}

module "ubuntu_22_04_latest" {
  source = "github.com/andreswebs/terraform-aws-ami-ubuntu"
}

locals {
  ami_id = module.ubuntu_22_04_latest.ami_id
}

resource "aws_instance" "task-6-2" {
  ami                    = local.ami_id
  instance_type          = "t2.micro"
  key_name               = var.ssh_key_name
  subnet_id              = module.vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = tls_private_key.ec2_ssh_key.private_key_pem
    host        = self.public_ip
  }
}

output "public_ip" {
  value = aws_instance.task-6-2.public_ip
}
