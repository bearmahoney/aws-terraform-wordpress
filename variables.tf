variable "region" {
  default = "us-east-1"
  type    = string
}

# Sets the default number of instances to 1 for testing
variable "webserver_count" {
  default = 1
  type    = number
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

