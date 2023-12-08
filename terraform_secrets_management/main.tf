terraform {
  required_providers {
    aws = {
    source = "hashicorp/aws" }
  }
}

# Create a creds file (locally) access per user basis
#! Cons - Creds will be saved on developer computers as text
provider "aws" {
  region              = "us-east-1"
  shared_config_files = ["~/.aws/credentials"]
  profile             = "personal"
}

# Create a DB in AWS (not recommended)
#! Cons -  NEVER store creds in plain text
resource "aws_db_instance" "my-test-db" {
  db_name           = "production-db"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  publicly_accessible  = true
  skip_final_snapshot  = true
  db_subnet_group_name = "test-subnet-group"

  # Do not save creds in plain test
  username = "root"
  password = "password"
}

# Create a DB in AWS (little better)
#! Creds will be still be visible in either the env. or C.L. history
resource "aws_db_instance" "my-test-db-2" {
  db_name           = "production-db-2"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  publicly_accessible  = true
  skip_final_snapshot  = true
  db_subnet_group_name = "test-subnet-group"

  # Using Enviorment Variables
  username = var.username
  password = var.password
}

# Create a DB in AWS (using AWS Secrets Manager)
#! More code and setup upfront
data "aws_secretsmanager_secret" "by-arn" {
  arn = "arn:aws:secretsmanager:us-east-1:123456789012:secret: dbCreds"
}

data "aws_secretsmanager_secret" "by-name" {
  name = "dbCreds"
}

locals {
  secret_data = jsondecode(data.aws_secretsmanager_secret.by-arn.secret_string)
  db_creds     = jsondecode(local.secret_data.SecretString)
  username     = local.db_creds.username
  password     = local.db_creds.password
}

# Create the DB
resource "aws_db_instance" "my-test-db-3" {
  db_name           = "production-db-3"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 10

  publicly_accessible  = true
  skip_final_snapshot  = true
  db_subnet_group_name = "test-subnet-group"
  
  username = local.username
  password = local.password
}




