variable "project_name" {
  type = map(string)
  default = {
    dev  = "carvis-dev"
    live = "carvis-live"
  }
}

variable "env" {
  description = "The environment: dev/live"
  default     = "dev"
}
