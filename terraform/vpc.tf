module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 1.0"

  name = "${var.project}-vpc"
  cidr = "${var.vpc_cidr}"

  azs = "${var.vpc_azs}"

  public_subnets  = "${var.vpc_public_subnets}"
  private_subnets = "${var.vpc_private_subnets}"

  enable_nat_gateway = false

  tags = {
    Terraform = "true"
    Owner     = "${var.resource_owner}"
  }
}
