resource "aws_acm_certificate" "this" {
  domain_name               = var.domain
  validation_method         = "DNS"
  subject_alternative_names = ["*.${var.domain}"]
}

resource "aws_acm_certificate_validation" "this" {
  certificate_arn         = aws_acm_certificate.this.arn
  validation_record_fqdns = [tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name]
}

output "certificate_validation_record_name" {
  value = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_name
}

output "certificate_validation_record_type" {
  value = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_type
}

output "certificate_validation_record_value" {
  value = tolist(aws_acm_certificate.this.domain_validation_options)[0].resource_record_value
}