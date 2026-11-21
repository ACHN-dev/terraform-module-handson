# Singapore
output "customer_profile_alb_dns_name" {
  description = "Customer profile ALB DNS name"
  value       = module.customer_profile_alb.dns_name
}

output "customer_profile_web_ui_url" {
  description = "Fake-service Web UI"
  value       = "http://${module.customer_profile_alb.dns_name}/ui/"
}

output "bastion_host_public_ip" {
  description = "Bastion public IP"
  value       = module.bastion_host.public_ip
}

output "customer_profile_private_ip" {
  description = "Customer profile private IP"
  value       = module.customer_profile.private_ip
}

# Tokyo
output "account_alb_dns_name" {
  description = "Account internal ALB DNS name"
  value       = module.account_alb.dns_name
}

output "account_private_ip" {
  description = "Account private IP"
  value       = module.account.private_ip
}

# London
output "statement_alb_dns_name" {
  description = "Statement internal ALB DNS name"
  value       = module.statement_alb.dns_name
}

output "statement_private_ip" {
  description = "Statement private IP"
  value       = module.statement.private_ip
}

# SSH Commands
output "ssh_bastion" {
  description = "SSH to Bastion host"
  value       = "ssh -i ${path.module}/bastion_host_key.pem ubuntu@${module.bastion_host.public_ip}"
}

output "ssh_customer_profile_proxy" {
  description = "SSH to Customer Profile via Bastion"
  value       = "ssh -i ${path.module}/customer_profile_key.pem -o ProxyJump=ubuntu@${module.bastion_host.public_ip} ubuntu@${module.customer_profile.private_ip}"
}

output "ssh_account_proxy" {
  description = "SSH to Account node in Tokyo via Bastion"
  value       = "ssh -i ${path.module}/account_key.pem -o ProxyJump=ubuntu@${module.bastion_host.public_ip} ubuntu@${module.account.private_ip}"
}

output "ssh_statement_proxy" {
  description = "SSH to Statement node in London via Bastion"
  value       = "ssh -i ${path.module}/statement_key.pem -o ProxyJump=ubuntu@${module.bastion_host.public_ip} ubuntu@${module.statement.private_ip}"
}
