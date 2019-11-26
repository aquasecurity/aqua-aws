module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = "${var.project}-vpc"
  cidr = var.vpc_cidr

  azs = var.vpc_azs

  # Aqua Server goes here
  public_subnets = var.vpc_public_subnets
  # Aqua Gateway goes here
  private_subnets = var.vpc_private_subnets
  # Aqua Postgres DB goes here
  database_subnets = var.vpc_database_subnets

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true

  tags = {
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

