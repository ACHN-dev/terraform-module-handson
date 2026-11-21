# --------------------------------------------------
# Security Groups
# --------------------------------------------------

# Bastion SG (Singapore)
module "bastion_host_sgp" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.singapore
  }

  name            = var.bastion_host_sgp_name
  use_name_prefix = false
  description     = "Bastion host SG"
  vpc_id          = module.customer_profile_vpc.vpc_id

  ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.ssh_allowed_cidr
      description = "SSH from allowed IP"
    }
  }

  egress_rules = {
    ssh-to-profile = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.customer_profile_vpc_cidr
      description = "SSH to customer profile EC2"
    }
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Outbound HTTP"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Outbound HTTPS"
    }
  }

  tags = {
    Name = var.bastion_host_sgp_name
  }
}

# Customer Profile EC2 SG (Singapore)
module "customer_profile_private_instance_sgp" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.singapore
  }

  name            = var.customer_profile_private_instance_sgp_name
  use_name_prefix = false
  description     = "Customer profile instance SG"
  vpc_id          = module.customer_profile_vpc.vpc_id

  ingress_rules = {
    http-from-alb = {
      from_port                    = 9091
      to_port                      = 9091
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.customer_profile_alb.security_group_id
      description                  = "HTTP 9091 from ALB"
    }
    ssh-from-bastion = {
      from_port                    = 22
      to_port                      = 22
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.bastion_host_sgp.id
      description                  = "SSH from Bastion"
    }
  }

  egress_rules = {
    http-to-account-alb = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = var.account_vpc_cidr
      description = "Call account ALB in Tokyo"
    }
    ssh-to-account-vpc = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.account_vpc_cidr
      description = "SCP to account instance in Tokyo"
    }
  }

  tags = {
    Name = var.customer_profile_private_instance_sgp_name
  }
}

# Account EC2 SG (Tokyo)
module "account_private_instance_sgp" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.tokyo
  }

  name            = var.account_private_instance_sgp_name
  use_name_prefix = false
  description     = "Account instance SG"
  vpc_id          = module.account_vpc.vpc_id

  ingress_rules = {
    http-from-account-alb = {
      from_port                    = 9092
      to_port                      = 9092
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.account_alb.security_group_id
      description                  = "HTTP 9092 from local ALB"
    }
    ssh-from-profile-vpc = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.customer_profile_vpc_cidr
      description = "SSH/SCP from Singapore"
    }
  }

  egress_rules = {
    http-to-statement-alb = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = var.statement_vpc_cidr
      description = "Call statement ALB in London"
    }
    ssh-to-statement-vpc = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.statement_vpc_cidr
      description = "SCP to statement instance in London"
    }
  }

  tags = {
    Name = var.account_private_instance_sgp_name
  }
}

# Statement EC2 SG (London)
module "statement_instance_sgp" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  providers = {
    aws = aws.london
  }

  name            = var.statement_instance_sgp_name
  use_name_prefix = false
  description     = "Statement instance SG"
  vpc_id          = module.statement_vpc.vpc_id

  ingress_rules = {
    http-from-statement-alb = {
      from_port                    = 9093
      to_port                      = 9093
      ip_protocol                  = "tcp"
      referenced_security_group_id = module.statement_alb.security_group_id
      description                  = "HTTP 9093 from local ALB"
    }
    ssh-from-account-vpc = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = var.account_vpc_cidr
      description = "SSH/SCP from Tokyo"
    }
  }

  egress_rules = {
    local-vpc-only = {
      from_port   = 0
      to_port     = 0
      ip_protocol = "-1"
      cidr_ipv4   = var.statement_vpc_cidr
      description = "Local VPC traffic only"
    }
  }

  tags = {
    Name = var.statement_instance_sgp_name
  }
}
