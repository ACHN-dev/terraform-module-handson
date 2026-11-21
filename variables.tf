# --------------------------------------------------
# Variables
# --------------------------------------------------

variable "ami_id" {
  description = "Ubuntu AMI ID (optional, will auto-detect if empty)"
  type        = string
  default     = ""
}

variable "create_key_pairs" {
  description = "Generate SSH key pairs automatically"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "Instance type for EC2 nodes"
  type        = string
  default     = "t3.micro"
}

variable "bastion_host_name" {
  description = "Bastion instance name"
  type        = string
  default     = "bastion_host"
}

variable "customer_profile_instance_name" {
  description = "Customer profile instance name"
  type        = string
  default     = "customer_profile"
}

variable "account_instance_name" {
  description = "Account instance name"
  type        = string
  default     = "account"
}

variable "statement_instance_name" {
  description = "Statement instance name"
  type        = string
  default     = "statement"
}

variable "bastion_host_key_name" {
  description = "Key pair name for bastion"
  type        = string
  default     = "bastion_host_key"
}

variable "customer_profile_key_name" {
  description = "Key pair name for customer profile"
  type        = string
  default     = "customer_profile_key"
}

variable "account_key_name" {
  description = "Key pair name for account"
  type        = string
  default     = "account_key"
}

variable "statement_key_name" {
  description = "Key pair name for statement"
  type        = string
  default     = "statement_key"
}

variable "ssh_allowed_cidr" {
  description = "Allowed CIDR for SSH to bastion"
  type        = string
  default     = "0.0.0.0/0"
}

variable "customer_profile_vpc_peering_name" {
  description = "Peering name between profile and account"
  type        = string
  default     = "customer_profile_vpc-to-account_vpc-peering"
}

variable "account_vpc_peering_name" {
  description = "Peering name between account and statement"
  type        = string
  default     = "account_vpc-to-statement_vpc-peering"
}

# Security group names
variable "bastion_host_sgp_name" {
  description = "Bastion SG name"
  type        = string
  default     = "bastion_host_sgp"
}

variable "customer_profile_alb_sgp_name" {
  description = "Customer profile ALB SG name"
  type        = string
  default     = "customer_profile_alb_sgp"
}

variable "customer_profile_private_instance_sgp_name" {
  description = "Customer profile private SG name"
  type        = string
  default     = "customer_profile_private_instance_sgp"
}

variable "account_alb_sgp_name" {
  description = "Account ALB SG name"
  type        = string
  default     = "account_alb_sgp"
}

variable "account_private_instance_sgp_name" {
  description = "Account private SG name"
  type        = string
  default     = "account_private_instance_sgp"
}

variable "statement_alb_sgp_name" {
  description = "Statement ALB SG name"
  type        = string
  default     = "statement_alb_sgp"
}

variable "statement_instance_sgp_name" {
  description = "Statement private SG name"
  type        = string
  default     = "statement_instance_sgp"
}

# ALB & TG names
variable "customer_profile_alb_name" {
  description = "Customer profile ALB name"
  type        = string
  default     = "customer-profile-alb"
}

variable "customer_profile_tgp_name" {
  description = "Customer profile target group name"
  type        = string
  default     = "customer-profile-tgp"
}

variable "account_alb_name" {
  description = "Account ALB name"
  type        = string
  default     = "account-alb"
}

variable "account_tgp_name" {
  description = "Account target group name"
  type        = string
  default     = "account-tgp"
}

variable "statement_alb_name" {
  description = "Statement ALB name"
  type        = string
  default     = "statement-alb"
}

variable "statement_tgp_name" {
  description = "Statement target group name"
  type        = string
  default     = "statement-tgp"
}

# Customer Profile VPC (Singapore)
variable "customer_profile_vpc_name" {
  description = "Customer profile VPC name"
  type        = string
  default     = "customer_profile_vpc"
}

variable "customer_profile_igw_name" {
  description = "IGW name for profile VPC"
  type        = string
  default     = "customer_profile_igw"
}

variable "customer_profile_public_rtb_name" {
  description = "Public route table name"
  type        = string
  default     = "customer_profile_public_rtb"
}

variable "customer_profile_private_rtb_name" {
  description = "Private route table name"
  type        = string
  default     = "customer_profile_private_rtb"
}

variable "customer_profile_vpc_cidr" {
  description = "Customer profile VPC CIDR"
  type        = string
  default     = "10.0.0.0/16"
}

variable "customer_profile_vpc_azs" {
  description = "AZs for customer profile VPC"
  type        = list(string)
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "customer_profile_vpc_public_subnets" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "customer_profile_vpc_public_subnet_names" {
  description = "Public subnet names"
  type        = list(string)
  default     = ["customer_profile_public_subnet1", "customer_profile_public_subnet2"]
}

variable "customer_profile_vpc_private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.101.0/24"]
}

variable "customer_profile_vpc_private_subnet_names" {
  description = "Private subnet names"
  type        = list(string)
  default     = ["customer_profile_private_subnet1", "customer_profile_private_subnet2"]
}

# Account VPC (Tokyo)
variable "account_vpc_name" {
  description = "Account VPC name"
  type        = string
  default     = "account_vpc"
}

variable "account_private_rtb_name" {
  description = "Private route table name"
  type        = string
  default     = "account_private_rtb"
}

variable "account_vpc_cidr" {
  description = "Account VPC CIDR"
  type        = string
  default     = "172.16.0.0/16"
}

variable "account_vpc_azs" {
  description = "AZs for account VPC"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

variable "account_vpc_private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["172.16.100.0/24", "172.16.101.0/24"]
}

variable "account_vpc_private_subnet_names" {
  description = "Private subnet names"
  type        = list(string)
  default     = ["account_private_subnet1", "account_private_subnet2"]
}

# Statement VPC (London)
variable "statement_vpc_name" {
  description = "Statement VPC name"
  type        = string
  default     = "statement_vpc"
}

variable "statement_private_rtb_name" {
  description = "Private route table name"
  type        = string
  default     = "statement_private_rtb"
}

variable "statement_vpc_cidr" {
  description = "Statement VPC CIDR"
  type        = string
  default     = "192.168.0.0/16"
}

variable "statement_vpc_azs" {
  description = "AZs for statement VPC"
  type        = list(string)
  default     = ["eu-west-2a", "eu-west-2b"]
}

variable "statement_vpc_private_subnets" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = ["192.168.100.0/24", "192.168.101.0/24"]
}

variable "statement_vpc_private_subnet_names" {
  description = "Private subnet names"
  type        = list(string)
  default     = ["statement_private_subnet1", "statement_private_subnet2"]
}
