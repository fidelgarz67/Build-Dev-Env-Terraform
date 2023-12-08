# Creating variables
# https://developer.hashicorp.com/terraform/language/values/variables
# This can prompt the user on data to run the terraform executions
# terraform.tfvars will take Precedence over this file
variable "host_os" {
    type = string
    default = "windows"
}