# --------------------------------------------------
# Ubuntu AMIs
# --------------------------------------------------

data "aws_ami" "ubuntu_singapore" {
  provider    = aws.singapore
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu_tokyo" {
  provider    = aws.tokyo
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_ami" "ubuntu_london" {
  provider    = aws.london
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

locals {
  ami_singapore = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu_singapore.id
  ami_tokyo     = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu_tokyo.id
  ami_london    = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu_london.id

  required_key_names = toset([
    var.bastion_host_key_name,
    var.customer_profile_key_name,
    var.account_key_name,
    var.statement_key_name
  ])
}

# --------------------------------------------------
# SSH Key Pairs
# --------------------------------------------------

# Generate private keys
resource "tls_private_key" "generated_keys" {
  for_each  = var.create_key_pairs ? local.required_key_names : toset([])
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Register key pairs in each region
resource "aws_key_pair" "keys_singapore" {
  provider   = aws.singapore
  for_each   = var.create_key_pairs ? local.required_key_names : toset([])
  key_name   = each.key
  public_key = tls_private_key.generated_keys[each.key].public_key_openssh
}

resource "aws_key_pair" "keys_tokyo" {
  provider   = aws.tokyo
  for_each   = var.create_key_pairs ? local.required_key_names : toset([])
  key_name   = each.key
  public_key = tls_private_key.generated_keys[each.key].public_key_openssh
}

resource "aws_key_pair" "keys_london" {
  provider   = aws.london
  for_each   = var.create_key_pairs ? local.required_key_names : toset([])
  key_name   = each.key
  public_key = tls_private_key.generated_keys[each.key].public_key_openssh
}

# Save private key to local pem file
resource "local_file" "generated_key_pems" {
  for_each        = var.create_key_pairs ? local.required_key_names : toset([])
  content         = tls_private_key.generated_keys[each.key].private_key_pem
  filename        = "${path.module}/${each.key}.pem"
  file_permission = "0400"
}

# --------------------------------------------------
# EC2 Instances
# --------------------------------------------------

# Bastion (Singapore)
module "bastion_host" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  providers = {
    aws = aws.singapore
  }

  name                        = var.bastion_host_name
  ami                         = local.ami_singapore
  instance_type               = var.instance_type
  key_name                    = var.bastion_host_key_name
  subnet_id                   = module.customer_profile_vpc.public_subnets[0]
  vpc_security_group_ids      = [module.bastion_host_sgp.id]
  associate_public_ip_address = true
  create_security_group       = false

  tags = {
    Name = var.bastion_host_name
  }

  depends_on = [aws_key_pair.keys_singapore]
}

# Customer Profile (Singapore)
module "customer_profile" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  providers = {
    aws = aws.singapore
  }

  name                   = var.customer_profile_instance_name
  ami                    = local.ami_singapore
  instance_type          = var.instance_type
  key_name               = var.customer_profile_key_name
  subnet_id              = module.customer_profile_vpc.private_subnets[0]
  vpc_security_group_ids = [module.customer_profile_private_instance_sgp.id]
  create_security_group  = false

  tags = {
    Name = var.customer_profile_instance_name
  }

  depends_on = [aws_key_pair.keys_singapore]
}

# Account (Tokyo)
module "account" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  providers = {
    aws = aws.tokyo
  }

  name                   = var.account_instance_name
  ami                    = local.ami_tokyo
  instance_type          = var.instance_type
  key_name               = var.account_key_name
  subnet_id              = module.account_vpc.private_subnets[0]
  vpc_security_group_ids = [module.account_private_instance_sgp.id]
  create_security_group  = false

  tags = {
    Name = var.account_instance_name
  }

  depends_on = [aws_key_pair.keys_tokyo]
}

# Statement (London)
module "statement" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  providers = {
    aws = aws.london
  }

  name                   = var.statement_instance_name
  ami                    = local.ami_london
  instance_type          = var.instance_type
  key_name               = var.statement_key_name
  subnet_id              = module.statement_vpc.private_subnets[0]
  vpc_security_group_ids = [module.statement_instance_sgp.id]
  create_security_group  = false

  tags = {
    Name = var.statement_instance_name
  }

  depends_on = [aws_key_pair.keys_london]
}

# Target Group Attachments
resource "aws_lb_target_group_attachment" "customer_profile_attachment" {
  provider         = aws.singapore
  target_group_arn = module.customer_profile_alb.target_groups[var.customer_profile_tgp_name].arn
  target_id        = module.customer_profile.id
  port             = 9091
}

resource "aws_lb_target_group_attachment" "account_attachment" {
  provider         = aws.tokyo
  target_group_arn = module.account_alb.target_groups[var.account_tgp_name].arn
  target_id        = module.account.id
  port             = 9092
}

resource "aws_lb_target_group_attachment" "statement_attachment" {
  provider         = aws.london
  target_group_arn = module.statement_alb.target_groups[var.statement_tgp_name].arn
  target_id        = module.statement.id
  port             = 9093
}
