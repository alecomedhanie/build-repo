resource "aws_flow_log" "vpc_flow_log" {
  log_destination_type = "cloud-watch-logs"
  vpc_id               = aws_vpc.my_vpc.id
  traffic_type         = "ALL"
  
  log_group_name       = aws_cloudwatch_log_group.vpc_flow_logs.name
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "vpc-flow-logs"
  retention_in_days = 7
}
