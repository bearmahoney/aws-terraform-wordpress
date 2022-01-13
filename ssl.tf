provider "acme" {
  server_url = var.prod_cert ? var.prod_letsencrypt_endpoint : var.staging_letsencrypt_endpoint
}

resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits  = "2048"
}

resource "acme_registration" "registration" {
  account_key_pem = tls_private_key.private_key.private_key_pem
  email_address   = "bear.mahoney@gmail.com"
}

resource "acme_certificate" "certificate" {
  account_key_pem = acme_registration.registration.account_key_pem
  common_name     = aws_route53_record.website.name

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = aws_route53_zone.main.zone_id
    }
  }

  depends_on = [acme_registration.registration]
}
