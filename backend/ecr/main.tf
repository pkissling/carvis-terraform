provider "aws" {
  region = "us-east-1"
}

resource "aws_ecrpublic_repository" "this" {
  repository_name = var.project_name
}
