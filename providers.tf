# --------------------------------------------------
# Providers setup (Multi-Region)
# --------------------------------------------------

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.29.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = ">= 2.4.0"
    }
  }
}

# Singapore
provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

# Tokyo
provider "aws" {
  alias  = "tokyo"
  region = "ap-northeast-1"
}

# London
provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

provider "aws" {
  region = "ap-southeast-1"
}
