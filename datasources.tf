# Get an EC2 intsance ami 
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ami
data "aws_ami" "server_ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}