# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"
}

# Create Default Security Group for the VPC
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id

  lifecycle {
    create_before_destroy = true  # Ensure no downtime
  }

  # Ingress rules (allow SSH and HTTPS)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow SSH from anywhere (adjust as needed)
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS traffic
  }

  # Egress rules (allow all outbound traffic)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound to anywhere
  }

  tags = {
    Name = "default-security-group"
  }
}

# Enable VPC Flow Logs to CloudWatch with encryption
resource "aws_flow_log" "vpc_flow_log" {
  log_destination_type = "cloud-watch-logs"
  vpc_id               = aws_vpc.my_vpc.id
  traffic_type         = "ALL"  # Capture all traffic

  log_group_name       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

# KMS Key for Encrypting CloudWatch Logs
resource "aws_kms_key" "log_group_key" {
  description         = "KMS key for encrypting CloudWatch Log Group"
  enable_key_rotation = true  # Best practice to enable key rotation

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::YOUR_ACCOUNT_ID:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# Create CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "vpc-flow-logs"
  retention_in_days = 365  # Retain logs for 1 year
  kms_key_id        = aws_kms_key.log_group_key.arn  # Enable encryption with KMS
}