# Create VPC
resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.0.0.0/24"

  tags = {
    Name        = "my-vpc"
    Environment = "production"
  }
}

# Restrict all traffic in the default security group
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id

  # Restrict ingress (block all inbound traffic)
  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
 }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Enable VPC Flow Logs
resource "aws_flow_log" "vpc_flow_log" {
  log_destination_type = "cloud-watch-logs"
  vpc_id               = aws_vpc.my_vpc.id
  traffic_type         = "ALL"  # Capture all traffic (ingress and egress)
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
          "AWS": "arn:aws:iam::203918868115:role/github.to.aws.cicd"
        },
        "Action": "kms:*",
        "Resource": "*"
      }
    ]
  }
  EOF
}

# CloudWatch Log Group for VPC Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "vpc-flow-logs"
  retention_in_days = 365  # Retain logs for 1 year
  kms_key_id        = aws_kms_key.log_group_key.arn
}
