variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "s3_images_id" {
  type = string
}

variable "dynamodb_requests_table_name" {
  type = string
}

variable "certificate_id" {
  type = string
}

variable "auth_client_id" {
  type      = string
  sensitive = true
}
variable "auth_client_secret" {
  type      = string
  sensitive = true
}
