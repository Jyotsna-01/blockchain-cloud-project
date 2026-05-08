variable "project_name" {
  type = string
}

variable "environment" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "Public subnets for EC2 and ALB"
}

variable "ec2_sg_id" {
  type        = string
  description = "Security group ID for EC2"
}

variable "alb_sg_id" {
  type        = string
  description = "Security group ID for ALB"
}

variable "ec2_instance_type" {
  type = string
}

variable "ec2_instance_profile_name" {
  type        = string
  description = "IAM instance profile to attach to EC2"
}

variable "db_host" {
  type        = string
  description = "RDS endpoint hostname"
}

variable "db_name" {
  type = string
}

variable "db_username" {
  type      = string
  sensitive = true
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "app_bucket_name" {
  type        = string
  description = "S3 bucket name for Django static/media files"
}