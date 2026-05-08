# ─── APPLICATION ACCESS ────────────────────────────────────────────────────────
output "app_url" {
  description = "Your application URL — open this in browser after deployment"
  value       = "http://${module.compute.alb_dns_name}"
}

output "alb_dns_name" {
  description = "Raw ALB DNS name"
  value       = module.compute.alb_dns_name
}

# ─── SSH ACCESS ────────────────────────────────────────────────────────────────
output "ssh_command" {
  description = "Ready-to-run SSH command to log into your EC2 server"
  value       = "ssh -i blockchain-ai-key.pem ec2-user@${module.compute.ec2_public_ip}"
}

output "ec2_public_ip" {
  description = "EC2 server public IP address"
  value       = module.compute.ec2_public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID (useful for AWS console)"
  value       = module.compute.ec2_instance_id
}

# ─── DATABASE ──────────────────────────────────────────────────────────────────
output "db_endpoint" {
  description = "RDS MySQL connection endpoint"
  value       = module.database.db_endpoint
}

output "db_host" {
  description = "RDS hostname"
  value       = module.database.db_host
}

output "db_name" {
  description = "Database name"
  value       = module.database.db_name
}

# ─── STORAGE ───────────────────────────────────────────────────────────────────
output "app_bucket_name" {
  description = "S3 bucket for application files"
  value       = module.storage.app_bucket_name
}

output "logs_bucket_name" {
  description = "S3 bucket for logs"
  value       = module.storage.logs_bucket_name
}

# ─── NETWORK ───────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

# ─── DEPLOYMENT SUMMARY ────────────────────────────────────────────────────────
output "deployment_summary" {
  description = "Quick summary of what was deployed"
  value = <<-EOT

  ╔══════════════════════════════════════════════════╗
  ║     BLOCKCHAIN-AI DEPLOYMENT COMPLETE            ║
  ╠══════════════════════════════════════════════════╣
  ║  App URL    : http://${module.compute.alb_dns_name}
  ║  EC2 IP     : ${module.compute.ec2_public_ip}
  ║  DB Host    : ${module.database.db_host}
  ║  S3 Bucket  : ${module.storage.app_bucket_name}
  ║  Region     : ap-south-1 (Mumbai)
  ╚══════════════════════════════════════════════════╝

  EOT
}