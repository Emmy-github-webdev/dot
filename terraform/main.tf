terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "my-portfolio-rails-bucket"
    key = "myapp/state.tfstate"
    region = "us-east-1"
  }
}


provider "aws" {
  region = var.region
}

resource "aws_vpc" "myapp-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name : "${var.env_prefix}-vpc"
  }
}


# Reference the subnet modules

module "myapp-subnet" {
  source = "./modules/network"
  subnet_cidr_block = var.subnet_cidr_block
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  vpc_id = aws_vpc.myapp-vpc.id
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
}

module "myapp-server" {
  source = "./modules/computes"
 vpc_id = aws_vpc.myapp-vpc.id
 my_ip = var.my_ip
 env_prefix = var.env_prefix
 image_name = var.image_name
 my_public_key_location = var.my_public_key_location
 instance_type = var.instance_type
 subnet_id = module.myapp-subnet.subnet.id
 avail_zone = var.avail_zone
}
