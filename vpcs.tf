# --------------------------------------------------
# VPCs & Subnets
# --------------------------------------------------

# Customer Profile VPC - Singapore (ap-southeast-1)
module "customer_profile_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  providers = {
    aws = aws.singapore
  }

  name = var.customer_profile_vpc_name
  cidr = var.customer_profile_vpc_cidr
  azs  = var.customer_profile_vpc_azs

  public_subnets       = var.customer_profile_vpc_public_subnets
  public_subnet_names  = var.customer_profile_vpc_public_subnet_names
  private_subnets      = var.customer_profile_vpc_private_subnets
  private_subnet_names = var.customer_profile_vpc_private_subnet_names

  create_igw = true
  igw_tags = {
    Name = var.customer_profile_igw_name
  }

  public_route_table_tags = {
    Name = var.customer_profile_public_rtb_name
  }

  private_route_table_tags = {
    Name = var.customer_profile_private_rtb_name
  }

  enable_nat_gateway   = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.customer_profile_vpc_name
  }
}

# Account VPC - Tokyo (ap-northeast-1)
module "account_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  providers = {
    aws = aws.tokyo
  }

  name = var.account_vpc_name
  cidr = var.account_vpc_cidr
  azs  = var.account_vpc_azs

  private_subnets      = var.account_vpc_private_subnets
  private_subnet_names = var.account_vpc_private_subnet_names

  create_igw = false

  private_route_table_tags = {
    Name = var.account_private_rtb_name
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.account_vpc_name
  }
}

# Statement VPC - London (eu-west-2)
module "statement_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.7.3"

  providers = {
    aws = aws.london
  }

  name = var.statement_vpc_name
  cidr = var.statement_vpc_cidr
  azs  = var.statement_vpc_azs

  private_subnets      = var.statement_vpc_private_subnets
  private_subnet_names = var.statement_vpc_private_subnet_names

  create_igw = false

  private_route_table_tags = {
    Name = var.statement_private_rtb_name
  }

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = var.statement_vpc_name
  }
}

# Subnet Name Tags
resource "aws_ec2_tag" "customer_profile_public_subnet_names" {
  provider    = aws.singapore
  count       = length(module.customer_profile_vpc.public_subnets)
  resource_id = module.customer_profile_vpc.public_subnets[count.index]
  key         = "Name"
  value       = var.customer_profile_vpc_public_subnet_names[count.index]
}

resource "aws_ec2_tag" "customer_profile_private_subnet_names" {
  provider    = aws.singapore
  count       = length(module.customer_profile_vpc.private_subnets)
  resource_id = module.customer_profile_vpc.private_subnets[count.index]
  key         = "Name"
  value       = var.customer_profile_vpc_private_subnet_names[count.index]
}

resource "aws_ec2_tag" "account_private_subnet_names" {
  provider    = aws.tokyo
  count       = length(module.account_vpc.private_subnets)
  resource_id = module.account_vpc.private_subnets[count.index]
  key         = "Name"
  value       = var.account_vpc_private_subnet_names[count.index]
}

resource "aws_ec2_tag" "statement_private_subnet_names" {
  provider    = aws.london
  count       = length(module.statement_vpc.private_subnets)
  resource_id = module.statement_vpc.private_subnets[count.index]
  key         = "Name"
  value       = var.statement_vpc_private_subnet_names[count.index]
}
