variable "region" {
  default = "us-east-1"
  type    = string
}

variable "notification_email" {
  default = "example@example.com"
  type = string
}

variable "domain" {
  default = "example.com"
  type    = string
}

variable "db_instance_type" {
  default = "db.t2.micro"
  type = string
}

variable "webserver" {
  type = map
  default = {
    "count" = "1"
    "instance_type" = "t2.micro"
    "ami_name" = "amzn2-ami-kernel-5.10-hvm*"
    "virt_type" = "hvm"
  }
}

# Sets default recovery for secrets to 0 for testing
variable "secret_recovery_days" {
  default = 0
  type    = number
}

# Sets default cert to use staging endpoint for testing
variable "prod_cert" {
  default = false
  type    = bool
}

# Staging endpoint for letsencrypt
variable "staging_letsencrypt_endpoint" {
  default = "https://acme-staging-v02.api.letsencrypt.org/directory"
  type    = string
}

# Prod endpoint for letsencrypt
variable "prod_letsencrypt_endpoint" {
  default = "https://acme-v02.api.letsencrypt.org/directory"
  type    = string
}
