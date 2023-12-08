#! Do NOT save or used creds like this: 
# Access Key = TEST_ACCESS_KEY
# Secret Access Key = TEST_SECRET_KEY

//Who are the providers of this terraform script
terraform {
  required_providers {
    aws = { source = "hashicorp/aws" }
  }
}

//add provider information (use personal creds that are saved on your computer)
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "vscode"
}
