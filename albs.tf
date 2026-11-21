# --------------------------------------------------
# Application Load Balancers
# --------------------------------------------------

# Customer Profile ALB (Public, Singapore)
module "customer_profile_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  providers = {
    aws = aws.singapore
  }

  name                       = var.customer_profile_alb_name
  load_balancer_type         = "application"
  internal                   = false
  vpc_id                     = module.customer_profile_vpc.vpc_id
  subnets                    = module.customer_profile_vpc.public_subnets
  enable_deletion_protection = false

  security_group_name = var.customer_profile_alb_sgp_name
  security_group_ingress_rules = {
    http-from-internet = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "HTTP from internet"
    }
  }
  security_group_egress_rules = {
    forward-to-profile-9091 = {
      from_port   = 9091
      to_port     = 9091
      ip_protocol = "tcp"
      cidr_ipv4   = var.customer_profile_vpc_cidr
      description = "Forward to profile instance on 9091"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = var.customer_profile_tgp_name
      }
    }
  }

  target_groups = {
    (var.customer_profile_tgp_name) = {
      name              = var.customer_profile_tgp_name
      protocol          = "HTTP"
      port              = 9091
      target_type       = "instance"
      create_attachment = false
      health_check = {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  tags = {
    Name = var.customer_profile_alb_name
  }
}

# Account ALB (Internal, Tokyo)
module "account_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  providers = {
    aws = aws.tokyo
  }

  name                       = var.account_alb_name
  load_balancer_type         = "application"
  internal                   = true
  vpc_id                     = module.account_vpc.vpc_id
  subnets                    = module.account_vpc.private_subnets
  enable_deletion_protection = false

  security_group_name = var.account_alb_sgp_name
  security_group_ingress_rules = {
    http-from-profile-vpc = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = var.customer_profile_vpc_cidr
      description = "HTTP from Singapore Profile VPC"
    }
  }
  security_group_egress_rules = {
    forward-to-account-9092 = {
      from_port   = 9092
      to_port     = 9092
      ip_protocol = "tcp"
      cidr_ipv4   = var.account_vpc_cidr
      description = "Forward to account instance on 9092"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = var.account_tgp_name
      }
    }
  }

  target_groups = {
    (var.account_tgp_name) = {
      name              = var.account_tgp_name
      protocol          = "HTTP"
      port              = 9092
      target_type       = "instance"
      create_attachment = false
      health_check = {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  tags = {
    Name = var.account_alb_name
  }
}

# Statement ALB (Internal, London)
module "statement_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "10.2.0"

  providers = {
    aws = aws.london
  }

  name                       = var.statement_alb_name
  load_balancer_type         = "application"
  internal                   = true
  vpc_id                     = module.statement_vpc.vpc_id
  subnets                    = module.statement_vpc.private_subnets
  enable_deletion_protection = false

  security_group_name = var.statement_alb_sgp_name
  security_group_ingress_rules = {
    http-from-account-vpc = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = var.account_vpc_cidr
      description = "HTTP from Tokyo Account VPC"
    }
  }
  security_group_egress_rules = {
    forward-to-statement-9093 = {
      from_port   = 9093
      to_port     = 9093
      ip_protocol = "tcp"
      cidr_ipv4   = var.statement_vpc_cidr
      description = "Forward to statement instance on 9093"
    }
  }

  listeners = {
    http = {
      port     = 80
      protocol = "HTTP"
      forward = {
        target_group_key = var.statement_tgp_name
      }
    }
  }

  target_groups = {
    (var.statement_tgp_name) = {
      name              = var.statement_tgp_name
      protocol          = "HTTP"
      port              = 9093
      target_type       = "instance"
      create_attachment = false
      health_check = {
        path                = "/"
        protocol            = "HTTP"
        matcher             = "200"
        interval            = 15
        timeout             = 5
        healthy_threshold   = 2
        unhealthy_threshold = 2
      }
    }
  }

  tags = {
    Name = var.statement_alb_name
  }
}
