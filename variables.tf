variable "project_name" {
  default = "carvis"
}

variable "env" {
  description = "The environment: dev/live"
  default     = "dev"
}

variable "domain" {
  default = "carvis.cloud"
}

variable "website_host_ip" {
  default = "75.2.60.5" # netlify
}

variable "website_cnames" {
  default = {
    dev  = "angry-wilson-eb9e32.netlify.app"
    live = "carvis-vue-live.pages.dev"
  }
}

variable "auth_client_id" {
  description = "Auth0 Client ID"
  type        = string
  sensitive   = true
}

variable "auth_client_secret" {
  description = "Auth0 Client Secret"
  type        = string
  sensitive   = true
}

variable "aws_account_id" {
  sensitive = true
}

variable "to_mail" {
  description = "Fowards all email to domain to this mail address"
  type        = string
}

