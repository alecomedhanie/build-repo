# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name        = "my-vpc"
    Environment = "production"
  }
}

# Restrict all traffic in the default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id

  lifecycle {
    create_before_destroy = true
  }

  # Restrict ingress (block all inbound traffic)
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Block all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Block traffic from all sources
  }

  # Restrict egress (block all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Block all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Block traffic to all destinations
  }

  tags = {
    Name = "restricted-default-security-group"
  }
}

# Enable VPC Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  log_destination_type = "cloud-watch-logs"
  vpc_id               = aws_vpc.my_vpc.id
  traffic_type         = "ALL"  # Capture all traffic (ingress and egress)
  log_group_name       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "vpc-flow-logs"
  retention_in_days = 365  # Retain logs for 1 year
}