resource "aws_route53_zone" "this" {
  name = var.domain
}

resource "aws_route53_record" "root" {
  zone_id = aws_route53_zone.this.zone_id
  name    = ""
  type    = "A"
  ttl     = "300"
  records = [var.website_host_ip]
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = "www"
  type    = "A"
  ttl     = "300"
  records = [var.website_host_ip]
}

resource "aws_route53_record" "certificate_validation" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.certificate_validation_record_name
  type    = var.certificate_validation_record_type
  records = [var.certificate_validation_record_value]
  ttl     = 60
}