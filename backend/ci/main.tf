resource "aws_iam_user" "github" {
  name = "${var.project_name}-github"
}
resource "aws_iam_access_key" "github" {
  user = aws_iam_user.github.name
}

resource "aws_iam_user_policy_attachment" "github_ebs_managed_updates" {
  user       = aws_iam_user.github.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_user_policy_attachment" "github_ebs_web_tier" {
  user       = aws_iam_user.github.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}
