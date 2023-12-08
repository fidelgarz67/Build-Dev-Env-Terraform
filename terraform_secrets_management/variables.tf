# Variables can have senitivity set to true, ensures that values will NOT
# be saved in your terraform logs


variable "username" {
  description = "Username for the master user in our DB"
  type        = string
  sensitive   = true
}

variable "password" {
  description = "Password for the master user in our DB"
  type        = string
  sensitive   = true
}