resource "aws_iam_user" "github" {
  name = "${var.project_name}-github"
}

resource "aws_iam_policy" "github_ecr" {
  name   = "${var.project_name}-github_access_ecr"
  policy = data.aws_iam_policy_document.ecr.json
}

resource "aws_iam_user_policy_attachment" "github_ecr" {
  user       = aws_iam_user.github.name
  policy_arn = aws_iam_policy.github_ecr.arn
}

resource "aws_iam_access_key" "github" {
  user = aws_iam_user.github.name
}

data "aws_iam_policy_document" "ecr" {
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetRepositoryPolicy",
      "ecr:DescribeRepositories",
      "ecr:DescribeImages",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_lambda" {
  name   = "${var.project_name}-github_update_lambdas"
  policy = data.aws_iam_policy_document.lambda.json
}

resource "aws_iam_user_policy_attachment" "github_lambda" {
  user       = aws_iam_user.github.name
  policy_arn = aws_iam_policy.github_lambda.arn
}

resource "aws_iam_user_policy_attachment" "github_ebs_managed_updates" {
  user       = aws_iam_user.github.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkManagedUpdatesCustomerRolePolicy"
}

resource "aws_iam_user_policy_attachment" "github_ebs_web_tier" {
  user       = aws_iam_user.github.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy_document" "lambda" {
  statement {
    actions = [
      "lambda:UpdateFunctionCode"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_sts" {
  name   = "${var.project_name}-github_use_sts"
  policy = data.aws_iam_policy_document.sts.json
}

resource "aws_iam_user_policy_attachment" "github_sts" {
  user       = aws_iam_user.github.name
  policy_arn = aws_iam_policy.github_sts.arn
}

data "aws_iam_policy_document" "sts" {
  statement {
    actions = [
      "sts:GetServiceBearerToken"
    ]
    resources = ["*"]
  }
}
