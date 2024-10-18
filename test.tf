resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/24"
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
  }
}

resource "aws_flow_log" "vpc_flow_log" {
  log_destination_type = "cloud-watch-logs"
  vpc_id               = aws_vpc.my_vpc.id
  traffic_type         = "ALL"
  
  log_group_name       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

resource "aws_kms_key" "log_group_key" {
  description = "KMS key for encrypting CloudWatch Log Group"
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "vpc-flow-logs"
  retention_in_days = 365  # Retain logs for 1 year
  kms_key_id        = aws_kms_key.log_group_key.arn  # Enable KMS encryption
}
