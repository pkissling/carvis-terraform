variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_api_gateway_integration_ids" {
  type = list(string)
}

variable "aws_api_gateway_resource_ids" {
  type = list(string)
}