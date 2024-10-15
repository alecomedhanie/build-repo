provider "aws" {
  region = "us-east-2"
}
resource "aws_vpc" "my-vpc" {
   cidr_block = "10.0.0.0/24"
}
