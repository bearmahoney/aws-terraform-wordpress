resource "aws_route53_zone" "main" {
  name = var.domain
}

resource "aws_route53_record" "website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = format("%s.%s", "www", var.domain)
  type    = "CNAME"
  ttl     = "30"

  records = [aws_lb.front_end.dns_name]
}
