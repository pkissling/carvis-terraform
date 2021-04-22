resource "aws_s3_bucket" "this" {
  bucket = "${var.project_name}-${var.env}-images"
  acl    = "private"

  cors_rule {
    allowed_headers = ["Content-Type"]
    allowed_methods = ["PUT", "GET"]
    allowed_origins = ["*"]
    max_age_seconds = 3000
  }
  versioning {
    enabled = true
  }
}

resource "aws_iam_policy" "this" {
  name   = "${var.project_name}-${var.env}-access_images_s3"
  policy = data.aws_iam_policy_document.this.json
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject"
    ]
    # resources = jsonencode(var.iam_roles_require_s3_access)
    resources = ["*"] # TODO
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each   = { for iam_role in var.iam_roles_require_s3_access : iam_role.name => iam_role }
  role       = each.value.name
  policy_arn = aws_iam_policy.this.arn
}