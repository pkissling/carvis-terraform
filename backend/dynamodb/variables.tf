variable "project_name" {
  type = string
}

variable "env" {
  type = string
}

variable "iam_role_names_require_dynamodb_access" {
  type = list(string)

}
