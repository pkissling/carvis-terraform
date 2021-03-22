variable "project_name" {
  type = map(any)
  default = {
    dev  = "carvis-dev"
    live = "carvis-live"
  }
}
variable "aws_region" {
  default = "eu-west-1"
}
variable "env" {
  description = "The environment: dev/live"
  default     = "dev"
}
