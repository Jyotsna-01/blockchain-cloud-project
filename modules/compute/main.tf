# ─── FETCH LATEST AMAZON LINUX 2023 AMI ────────────────────────────────────────
# AMI = Amazon Machine Image = the OS snapshot your EC2 boots from.
# Instead of hardcoding an AMI ID (which changes per region),
# we dynamically fetch the latest Amazon Linux 2023 AMI for ap-south-1.
# This way your code always works even if AWS updates the image.
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

# ─── KEY PAIR ──────────────────────────────────────────────────────────────────
# To SSH into EC2, you need a key pair (like a password but cryptographic).
# We generate it in Terraform so it's tracked as infrastructure.
# The private key will be saved locally — keep it safe, never commit to GitHub.
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ec2_key.public_key_openssh

  tags = {
    Name        = "${var.project_name}-key"
    Environment = var.environment
    Project     = var.project_name
  }
}

# Save private key locally so you can SSH into EC2 later
resource "local_file" "private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "${path.module}/../../${var.project_name}-key.pem"
  file_permission = "0400"   # Read-only for owner — SSH requires this permission
}

# ─── EC2 INSTANCE ──────────────────────────────────────────────────────────────
resource "aws_instance" "app" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.ec2_instance_type
  subnet_id              = var.public_subnet_ids[0]   # Place in first public subnet
  vpc_security_group_ids = [var.ec2_sg_id]
  iam_instance_profile   = var.ec2_instance_profile_name
  key_name               = aws_key_pair.ec2_key.key_name

  # user_data runs ONCE on first boot — installs everything automatically
  # This is your entire Django deployment automated into a shell script
  user_data = base64encode(templatefile("${path.module}/userdata.sh", {
    db_host         = var.db_host
    db_name         = var.db_name
    db_username     = var.db_username
    db_password     = var.db_password
    app_bucket_name = var.app_bucket_name
    project_name    = var.project_name
  }))

  root_block_device {
    volume_size           = 20          # 20 GB root disk
    volume_type           = "gp3"       # gp3 = faster and cheaper than gp2
    encrypted             = true        # Encrypt the OS disk too
    delete_on_termination = true
  }

  tags = {
    Name        = "${var.project_name}-app-server"
    Environment = var.environment
    Project     = var.project_name
    Role        = "WebServer"
  }
}

# ─── APPLICATION LOAD BALANCER ─────────────────────────────────────────────────
# ALB distributes incoming HTTP traffic to your EC2 instances.
# Even with 1 EC2, using an ALB is best practice — it gives you
# a stable DNS name, health checks, and easy SSL termination later.
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false             # Internet-facing
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids   # Spans both public subnets (2 AZs)

  enable_deletion_protection = false     # Allow deletion in dev

  tags = {
    Name        = "${var.project_name}-alb"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── TARGET GROUP ──────────────────────────────────────────────────────────────
# A Target Group is the list of EC2 instances the ALB forwards traffic to.
# Health check: ALB pings /health/ every 30s — if EC2 fails, ALB stops sending traffic.
resource "aws_lb_target_group" "app" {
  name     = "${var.project_name}-tg"
  port     = 8000           # Django runs on port 8000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    healthy_threshold   = 2      # 2 successful checks = healthy
    unhealthy_threshold = 3      # 3 failed checks = unhealthy
    timeout             = 5      # Wait 5s for response
    interval            = 30     # Check every 30 seconds
    path                = "/"    # Hit the homepage to check health
    matcher             = "200,302"  # Accept 200 OK or 302 redirect as healthy
  }

  tags = {
    Name        = "${var.project_name}-tg"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── ATTACH EC2 TO TARGET GROUP ────────────────────────────────────────────────
resource "aws_lb_target_group_attachment" "app" {
  target_group_arn = aws_lb_target_group.app.arn
  target_id        = aws_instance.app.id
  port             = 8000
}

# ─── ALB LISTENER ──────────────────────────────────────────────────────────────
# The Listener watches port 80 on the ALB.
# When a request comes in on port 80 → forward it to the target group.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}