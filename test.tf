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
    protocol    = "-1"  # This means all protocols are blocked
    cidr_blocks = ["0.0.0.0/0"]  # Block traffic from all sources
  }

  # Restrict egress (block all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # This means all protocols are blocked
    cidr_blocks = ["0.0.0.0/0"]  # Block traffic to all destinations
  }

  tags = {
    Name = "restricted-default-security-group"
  }
}