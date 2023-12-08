# to deploy (via terminal) - 'terraform plan' then 'terraform apply'
# to delete (via terminal) - 'terraform destroy'
# to replace a resource (via terminal) - 'terraform apply -replace ${resource}'
# to view output (via terminal) - 'terraform output'

# Create a VPC Resource
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc.html
resource "aws_vpc" "mtc_vpc" {
  cidr_block           = "10.123.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags                 = { Name = "dev" }
}

# Create a Subnet
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "mtc_public_subnet" {
  vpc_id                  = aws_vpc.mtc_vpc.id
  cidr_block              = "10.123.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags                    = { Name = "dev-public" }
}

# Create an internet gateway
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "mtc_internet_gateway" {
  vpc_id = aws_vpc.mtc_vpc.id
  tags   = { Name = "dev-igw" }
}

# Create a Route Table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route
resource "aws_route_table" "mtc_public_rt" {
  vpc_id = aws_vpc.mtc_vpc.id
  tags   = { Name = "dev_public_rt" }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.mtc_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.mtc_internet_gateway.id
}

# Create a route table association (For the route table and subnet)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "mtc_public_association" {
  subnet_id      = aws_subnet.mtc_public_subnet.id
  route_table_id = aws_route_table.mtc_public_rt.id
}

# Create a Security Group
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
# ingress - who can send traffic to the SG
# egress - who can the SG send traffic to
#! Usually you want the ingress to be very limited and not WIDE OPEN
resource "aws_security_group" "mtc_sg" {
  name        = "dev_sg"
  description = "Dev Security Group"
  vpc_id      = aws_vpc.mtc_vpc.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create a key/pair that will be used by a resource (in terraform) to SSH into the EC2 instance
# (in terminal) - ssh-keygen -t ed25519, then rename the file and save in a dir
resource "aws_key_pair" "mtc_auth" {
  key_name   = "mtckey"
  public_key = file("~/.ssh/mtckey.pub")
}

# Create an EC2 Instance
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
#! Provisioners are a LAST RESORT (NOT usually in use for production)
# https://developer.hashicorp.com/terraform/language/resources/provisioners/syntax#
# (template file) - https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file
# (Conditionals (in the interpreter)) - https://developer.hashicorp.com/terraform/language/expressions/conditionals
# If on Windows; interpretor will be 'interpreter = ["Powershell", "-command"]'
resource "aws_instance" "dev_node" {
  instance_type          = "t2.micro"
  ami                    = data.aws_ami.server_ami.id
  key_name               = aws_key_pair.mtc_auth.key_name
  vpc_security_group_ids = [aws_security_group.mtc_sg.id]
  subnet_id              = aws_subnet.mtc_public_subnet.id
  user_data = file("userdata.tpl")

  root_block_device { volume_size = 10 }
  tags = { Name = "dev-node" }

  provisioner "local-exec" {
    command = templatefile("${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
      user = "ubuntu",
      identityfile = "~/.ssh/mtckey"
    })
    interpreter = var.host_os == "mac" ? ["bash", "-c"] : ["Powershell", -"command"]
  }
}

# Log in BEFORE the provisioner
# Use the appropriate mtckey as well as public IP Address
# To SSH into the instance (in terminal) - 'ssh -i ~/.ssh/mtckey ubuntu@3.94.21.167'
# Check if docker is installed from the user data (after ssh) - 'docker --version'
# To Logout of the instance (in terminal) - logout

# Log in AFTER the provisioner
# To see if the provisioner was created (in terminal) - 'cat ~/.ssh/config'
# View -> Command Palette -> SSH Connect to Host, Open new terminal and you are in the remote connection
# To Logout of the instance (in terminal) - exit
