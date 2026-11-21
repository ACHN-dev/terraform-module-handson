# --------------------------------------------------
# VPC Peering (Cross-Region)
# --------------------------------------------------

# Singapore <-> Tokyo Peering
resource "aws_vpc_peering_connection" "customer_profile_vpc_to_account_vpc" {
  provider    = aws.singapore
  vpc_id      = module.customer_profile_vpc.vpc_id
  peer_vpc_id = module.account_vpc.vpc_id
  peer_region = "ap-northeast-1"
  auto_accept = false

  tags = {
    Name = var.customer_profile_vpc_peering_name
  }
}

resource "aws_vpc_peering_connection_accepter" "account_peer_accept" {
  provider                  = aws.tokyo
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_profile_vpc_to_account_vpc.id
  auto_accept               = true

  tags = {
    Name = "${var.customer_profile_vpc_peering_name}-accept"
  }
}

resource "aws_route" "customer_profile_vpc_private_to_account_vpc" {
  provider                  = aws.singapore
  count                     = length(module.customer_profile_vpc.private_route_table_ids)
  route_table_id            = module.customer_profile_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.account_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_profile_vpc_to_account_vpc.id
}

resource "aws_route" "account_vpc_private_to_customer_profile_vpc" {
  provider                  = aws.tokyo
  count                     = length(module.account_vpc.private_route_table_ids)
  route_table_id            = module.account_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.customer_profile_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.customer_profile_vpc_to_account_vpc.id

  depends_on = [aws_vpc_peering_connection_accepter.account_peer_accept]
}

# Tokyo <-> London Peering
resource "aws_vpc_peering_connection" "account_vpc_to_statement_vpc" {
  provider    = aws.tokyo
  vpc_id      = module.account_vpc.vpc_id
  peer_vpc_id = module.statement_vpc.vpc_id
  peer_region = "eu-west-2"
  auto_accept = false

  tags = {
    Name = var.account_vpc_peering_name
  }
}

resource "aws_vpc_peering_connection_accepter" "statement_peer_accept" {
  provider                  = aws.london
  vpc_peering_connection_id = aws_vpc_peering_connection.account_vpc_to_statement_vpc.id
  auto_accept               = true

  tags = {
    Name = "${var.account_vpc_peering_name}-accept"
  }
}

resource "aws_route" "account_vpc_private_to_statement_vpc" {
  provider                  = aws.tokyo
  count                     = length(module.account_vpc.private_route_table_ids)
  route_table_id            = module.account_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.statement_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.account_vpc_to_statement_vpc.id
}

resource "aws_route" "statement_vpc_private_to_account_vpc" {
  provider                  = aws.london
  count                     = length(module.statement_vpc.private_route_table_ids)
  route_table_id            = module.statement_vpc.private_route_table_ids[count.index]
  destination_cidr_block    = var.account_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.account_vpc_to_statement_vpc.id

  depends_on = [aws_vpc_peering_connection_accepter.statement_peer_accept]
}
