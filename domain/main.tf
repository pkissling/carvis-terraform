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

resource "aws_route53_record" "mail_identity_validation" {
  count   = var.env == "live" ? 3 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = "${element(var.mail_domain_validation_dkim_tokens, count.index)}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${element(var.mail_domain_validation_dkim_tokens, count.index)}.dkim.amazonses.com"]
}

# Record to allow receiving mails
resource "aws_route53_record" "mail_receiver_validation" {
  count   = var.env == "live" ? 1 : 0
  zone_id = aws_route53_zone.this.zone_id
  name    = var.domain
  type    = "MX"
  ttl     = "300"
  records = ["10 inbound-smtp.eu-west-1.amazonaws.com"] # Static value
}