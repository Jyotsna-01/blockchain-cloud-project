output "alb_sg_id" {
  description = "Security Group ID for the Load Balancer"
  value       = aws_security_group.alb.id
}

output "ec2_sg_id" {
  description = "Security Group ID for EC2"
  value       = aws_security_group.ec2.id
}

output "rds_sg_id" {
  description = "Security Group ID for RDS"
  value       = aws_security_group.rds.id
}

output "ec2_instance_profile_name" {
  description = "IAM Instance Profile name to attach to EC2"
  value       = aws_iam_instance_profile.ec2_profile.name
}