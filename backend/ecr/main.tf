resource "aws_ecrpublic_repository" "this" {
  repository_name = var.project_name
}
