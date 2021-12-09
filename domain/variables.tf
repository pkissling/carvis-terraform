variable "domain" {
  type = string
}

variable "env" {
  type = string
}

variable "website_host_ip" {
  type = string
}

variable "website_cname" {
  type = string
}

variable "certificate_validation_record_name" {
  type = string
}

variable "certificate_validation_record_type" {
  type = string
}

variable "certificate_validation_record_value" {
  type = string
}

variable "api_cname" {
  type = string
}

variable "mail_domain_validation_dkim_tokens" {
  type = list(string)
}
