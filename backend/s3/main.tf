resource "aws_s3_bucket" "images" {
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

resource "aws_iam_policy" "images" {
  name   = "${var.project_name}-${var.env}-access_images_s3"
  policy = data.aws_iam_policy_document.images.json
}

data "aws_iam_policy_document" "images" {
  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
      "s3:Put*",
      "s3:Delete*"
    ]
    resources = [
      aws_s3_bucket.images.arn,
      "${aws_s3_bucket.images.arn}/*"
    ]
  }
}

resource "aws_iam_role_policy_attachment" "images" {
  count      = length(var.iam_role_names_require_s3_access)
  role       = var.iam_role_names_require_s3_access[count.index]
  policy_arn = aws_iam_policy.images.arn
}

output "s3_images_id" {
  value = aws_s3_bucket.images.id
}
