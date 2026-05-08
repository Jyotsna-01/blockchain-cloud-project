# ─── VPC ───────────────────────────────────────────────────────────────────────
# The VPC is your private data center in AWS. Everything lives inside this.
# 10.0.0.0/16 gives us 65,536 IP addresses to distribute across subnets.
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true   # Allows EC2 instances to get DNS names
  enable_dns_support   = true

  tags = {
    Name        = "${var.project_name}-vpc"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── INTERNET GATEWAY ──────────────────────────────────────────────────────────
# The IGW is the door between your VPC and the public internet.
# Without this, nothing inside can reach the outside world.
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-igw"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── PUBLIC SUBNETS ────────────────────────────────────────────────────────────
# Public subnets are where internet-facing resources live (EC2, Load Balancer).
# count = 2 means we create 2 subnets across 2 Availability Zones for redundancy.
# data.aws_availability_zones fetches the AZ names automatically for ap-south-1.
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true   # EC2s in this subnet get a public IP automatically

  tags = {
    Name        = "${var.project_name}-public-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "Public"
  }
}

# ─── PRIVATE SUBNETS ───────────────────────────────────────────────────────────
# Private subnets are for resources that should NEVER be directly reachable
# from the internet — like your MySQL database (RDS).
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name        = "${var.project_name}-private-subnet-${count.index + 1}"
    Environment = var.environment
    Project     = var.project_name
    Type        = "Private"
  }
}

# ─── PUBLIC ROUTE TABLE ────────────────────────────────────────────────────────
# A route table is a set of rules that decides where network traffic goes.
# This one says: "any traffic going to 0.0.0.0/0 (internet) → go through the IGW"
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name        = "${var.project_name}-public-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

# ─── ASSOCIATE PUBLIC SUBNETS WITH PUBLIC ROUTE TABLE ─────────────────────────
# Subnets don't automatically use a route table — you must explicitly link them.
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ─── PRIVATE ROUTE TABLE ───────────────────────────────────────────────────────
# Private subnets have no route to the internet — that's the security point.
# Traffic stays inside the VPC only.
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.project_name}-private-rt"
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}