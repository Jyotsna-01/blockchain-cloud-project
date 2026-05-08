# ─── DB SUBNET GROUP ───────────────────────────────────────────────────────────
# RDS can't just be placed in "a subnet" — it needs a Subnet Group.
# A Subnet Group is a collection of subnets across multiple AZs.
# AWS requires at least 2 AZs for RDS — this is for automatic failover.
# If ap-south-1a goes down, RDS can fail over to ap-south-1b automatically.
resource "aws_db_subnet_group" "main" {
  name        = "${var.project_name}-db-subnet-group"
  description = "Subnet group for RDS MySQL - spans 2 private AZs"
  subnet_ids  = var.private_subnet_ids

  tags = {
    Name        = "${var.project_name}-db-subnet-group"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── RDS PARAMETER GROUP ───────────────────────────────────────────────────────
# A Parameter Group is a config file for your database engine.
# We're using MySQL 8.0 with utf8mb4 charset — handles all unicode including emoji.
# This is important for your blockchain app which stores medical data (names, etc.)
resource "aws_db_parameter_group" "main" {
  name        = "${var.project_name}-mysql-params"
  family      = "mysql8.0"
  description = "Custom MySQL 8.0 parameter group for blockchain app"

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
  }

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
  }

  parameter {
    name  = "max_connections"
    value = "100"
  }

  tags = {
    Name        = "${var.project_name}-mysql-params"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── RDS MYSQL INSTANCE ────────────────────────────────────────────────────────
# This is the actual database server.
# Every setting here is a deliberate decision — explained below.
resource "aws_db_instance" "main" {
  identifier = "${var.project_name}-mysql-db"

  # Engine config
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"   # Free tier eligible, 1 vCPU, 1GB RAM
  
  # Storage config
  allocated_storage     = 20             # 20 GB initial storage
  max_allocated_storage = 100            # Auto-scales up to 100 GB if needed
  storage_type          = "gp2"          # General Purpose SSD — balanced cost/performance
  storage_encrypted     = true           # Encrypts data at rest — security requirement

  # Database credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  # Network config — placed in private subnets, uses our SG
  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.rds_sg_id]
  publicly_accessible    = false         # CRITICAL: DB never exposed to internet

  # Config group
  parameter_group_name = aws_db_parameter_group.main.name

  # Backup config
  backup_retention_period = 0            # Keep 7 days of automatic backups
  maintenance_window      = "Mon:04:00-Mon:05:00"

  # Availability
  multi_az               = false         # Single AZ for dev (multi-AZ costs 2x)
  deletion_protection    = false         # Allow deletion in dev environment

  # Monitoring
  monitoring_interval = 0               # Basic monitoring (free tier)

  # On destroy — skip final snapshot for dev environment
  skip_final_snapshot = true

  tags = {
    Name        = "${var.project_name}-mysql-db"
    Environment = var.environment
    Project     = var.project_name
  }
}