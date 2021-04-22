variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "iam_roles_require_s3_access" {
  type = set(object({
    name = string
    arn  = string
  }))
}
