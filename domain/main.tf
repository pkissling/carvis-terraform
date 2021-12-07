resource "aws_route53_zone" "this" {
  name = var.domain
}
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.env == "live" ? "" : var.env
  type    = var.env == "live" ? "A" : "CNAME"
  ttl     = "300"
  records = var.env == "live" ? [var.website_host_ip] : [var.website_cname]
}
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.env == "live" ? "www" : "www.${var.env}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.website_cname]
}

resource "aws_route53_record" "api" {
  count   = var.env == "live" ? 1 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = var.env == "live" ? "api" : "api.${var.env}"
  type    = "CNAME"
  ttl     = "300"
  records = [var.api_cname]
}

resource "aws_route53_record" "certificate_validation" {
  zone_id = aws_route53_zone.this.zone_id
  name    = var.certificate_validation_record_name
  type    = var.certificate_validation_record_type
  records = [var.certificate_validation_record_value]
  ttl     = 60
}
