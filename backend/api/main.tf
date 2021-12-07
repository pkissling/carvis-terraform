module "beanstalk" {
  source             = "./beanstalk"
  project_name       = var.project_name
  env                = var.env
  certificate_id     = var.certificate_id
  auth_client_id     = var.auth_client_id
  auth_client_secret = var.auth_client_secret
}

output "iam_role_names_require_s3_access" {
  value = [module.beanstalk.ebs_iam_role_name]
}

output "iam_role_names_require_dynamodb_access" {
  value = [module.beanstalk.ebs_iam_role_name]
}

output "ebs_cname" {
  value = module.beanstalk.ebs_cname
}

output "ebs_iam_role_name" {
  value = module.beanstalk.ebs_iam_role_name
}
