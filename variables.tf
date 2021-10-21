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
    live = "condescending-bohr-dc4006.netlify.app"
  }
}