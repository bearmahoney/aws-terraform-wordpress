resource "aws_route53_zone" "main" {
  name = "bearmahoney.xyz"
}

resource "aws_route53_record" "website" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "www.bearmahoney.xyz"
  type    = "CNAME"
  ttl     = "30"

  records = [aws_lb.front_end.dns_name]
}
