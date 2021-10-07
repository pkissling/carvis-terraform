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