# ─── SECURITY GROUP 1: LOAD BALANCER ───────────────────────────────────────────
# The ALB faces the internet. It accepts HTTP (80) and HTTPS (443) from anywhere.
# It can send ALL outbound traffic out (needed to forward to EC2).
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS from internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-alb-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── SECURITY GROUP 2: EC2 (DJANGO APP) ────────────────────────────────────────
# EC2 only accepts traffic from the ALB security group — not the open internet.
# Port 8000 = Django's default port.
# Port 22 = SSH so you can log in to manage/debug the server.
resource "aws_security_group" "ec2" {
  name        = "${var.project_name}-ec2-sg"
  description = "Security group for EC2 Django app server"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow app traffic only from ALB"
    from_port       = 8000
    to_port         = 8000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]  # ← Only from ALB, not internet
  }

  ingress {
    description = "Allow SSH for admin access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # In production, restrict this to your own IP
  }

  egress {
    description = "Allow all outbound (to reach RDS, internet for pip installs etc.)"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-ec2-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── SECURITY GROUP 3: RDS (MYSQL DATABASE) ────────────────────────────────────
# RDS only accepts MySQL traffic (port 3306) from the EC2 security group.
# The database is in a private subnet AND has a restrictive SG — double protection.
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-rds-sg"
  description = "Security group for RDS MySQL database"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow MySQL only from EC2 app server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2.id]  # ← Only from EC2, nothing else
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-rds-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── IAM ROLE FOR EC2 ──────────────────────────────────────────────────────────
# IAM Roles define WHAT AWS SERVICES the EC2 can talk to.
# This is different from Security Groups (which control network traffic).
# Think: SG = network bouncer, IAM = permission slip for AWS services.
resource "aws_iam_role" "ec2_role" {
  name = "${var.project_name}-ec2-role"

  # This "assume_role_policy" says: "EC2 service is allowed to use this role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-ec2-role"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── IAM POLICY: WHAT EC2 CAN DO ───────────────────────────────────────────────
# Grants EC2 permission to read/write S3 (for file uploads/static files)
# and read SSM Parameter Store (for secrets like DB password).
resource "aws_iam_policy" "ec2_policy" {
  name        = "${var.project_name}-ec2-policy"
  description = "Allows EC2 to access S3 and SSM for the blockchain app"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      },
      {
        Sid    = "SSMAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath"
        ]
        Resource = "*"
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# ─── ATTACH POLICY TO ROLE ─────────────────────────────────────────────────────
resource "aws_iam_role_policy_attachment" "ec2_policy_attach" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_policy.arn
}

# ─── INSTANCE PROFILE ──────────────────────────────────────────────────────────
# EC2 can't directly use an IAM Role — it needs an "Instance Profile" wrapper.
# Think of it as the card holder that lets EC2 carry the permission slip.
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${var.project_name}-ec2-profile"
  role = aws_iam_role.ec2_role.name
}