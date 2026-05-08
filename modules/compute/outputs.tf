output "alb_dns_name" {
  description = "ALB DNS name — use this to access your app in browser"
  value       = aws_lb.main.dns_name
}

output "ec2_public_ip" {
  description = "EC2 public IP for SSH access"
  value       = aws_instance.app.public_ip
}

output "ec2_instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.app.id
}