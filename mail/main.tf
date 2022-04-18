resource "aws_ses_domain_identity" "this" {
  count  = var.env == "live" ? 1 : 0
  domain = var.domain
}

resource "aws_ses_domain_dkim" "this" {
  count  = var.env == "live" ? 1 : 0
  domain = aws_ses_domain_identity.this[0].domain
}

resource "aws_ses_email_identity" "recipient" {
  count = var.env == "live" ? 1 : 0
  email = var.to_mail
}

resource "aws_ses_receipt_rule_set" "default" {
  count         = var.env == "live" ? 1 : 0
  rule_set_name = "default"
}

resource "aws_ses_active_receipt_rule_set" "default" {
  count         = var.env == "live" ? 1 : 0
  rule_set_name = aws_ses_receipt_rule_set.default[0].id
}

# Write incoming mails to s3 and trigger lambda
resource "aws_ses_receipt_rule" "forward_mails" {
  count         = var.env == "live" ? 1 : 0
  name          = "${var.project_name}-${var.env}-forward_mails"
  rule_set_name = aws_ses_active_receipt_rule_set.default[0].id
  recipients    = [var.domain]
  enabled       = true
  scan_enabled  = true

  s3_action {
    bucket_name = aws_s3_bucket.incoming_mails[0].id
    position    = 1
  }

  lambda_action {
    function_arn    = aws_lambda_function.mail_forwarder[0].arn
    invocation_type = "Event"
    position        = 2
  }
}

resource "aws_s3_bucket" "incoming_mails" {
  count  = var.env == "live" ? 1 : 0
  bucket = "${var.project_name}-${var.env}-incoming-mails"
  acl    = "private"
}

resource "aws_s3_bucket_policy" "ses_write_to_incoming_mails_bucket" {
  count  = var.env == "live" ? 1 : 0
  bucket = aws_s3_bucket.incoming_mails[0].id
  policy = data.aws_iam_policy_document.ses_to_incoming_mails_bucket[0].json
}

data "aws_iam_policy_document" "ses_to_incoming_mails_bucket" {
  count = var.env == "live" ? 1 : 0
  statement {
    actions = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:Referer"
      values   = [var.aws_account_id]
    }

    resources = ["${aws_s3_bucket.incoming_mails[0].arn}/*"]
  }
}

resource "aws_lambda_function" "mail_forwarder" {
  count         = var.env == "live" ? 1 : 0
  function_name = "${var.project_name}-${var.env}_mail-forwarder"
  role          = aws_iam_role.mail_forwarder[0].arn
  handler       = "mail-forwarder.handler"
  runtime       = "nodejs12.x"

  filename         = "./target/mail-forwarder.zip"
  source_code_hash = data.archive_file.mail_forwarder_zip.output_base64sha256

  environment {
    variables = {
      TO_MAIL               = var.to_mail
      FROM_MAIL             = "mailforwarder@${var.domain}"
      BUCKET_INCOMING_MAILS = aws_s3_bucket.incoming_mails[0].id
      SUBJECT_PREFIX        = "${var.domain} | "
    }
  }
}

data "archive_file" "mail_forwarder_zip" {
  type        = "zip"
  source_file = "./mail/mail-forwarder.js"
  output_path = "./target/mail-forwarder.zip"
}

resource "aws_iam_role" "mail_forwarder" {
  count              = var.env == "live" ? 1 : 0
  name               = "${var.domain}-mail_forwarder"
  assume_role_policy = data.aws_iam_policy_document.mail_forwarder[0].json
}

data "aws_iam_policy_document" "mail_forwarder" {
  count = var.env == "live" ? 1 : 0
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_lambda_permission" "mail_forwarder" {
  count          = var.env == "live" ? 1 : 0
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.mail_forwarder[0].arn
  principal      = "ses.amazonaws.com"
  source_account = var.aws_account_id
}

resource "aws_iam_role_policy_attachment" "ebs_send_mails" {
  count      = var.env == "live" ? 1 : 0
  role       = var.ebs_iam_role_name
  policy_arn = aws_iam_policy.send_emails[0].arn
}

resource "aws_iam_role_policy_attachment" "mail_forwarder_send_mails" {
  count      = var.env == "live" ? 1 : 0
  role       = aws_iam_role.mail_forwarder[0].name
  policy_arn = aws_iam_policy.send_emails[0].arn
}

resource "aws_iam_role_policy_attachment" "mail_forwarder_access_incoming_mails_bucket" {
  count      = var.env == "live" ? 1 : 0
  role       = aws_iam_role.mail_forwarder[0].name
  policy_arn = aws_iam_policy.mail_forwarder_access_incoming_mails_bucket[0].arn
}

resource "aws_iam_policy" "mail_forwarder_access_incoming_mails_bucket" {
  count  = var.env == "live" ? 1 : 0
  name   = "${var.project_name}-${var.env}-access-bucket"
  policy = data.aws_iam_policy_document.access_incoming_mails_bucket[0].json
}

data "aws_iam_policy_document" "access_incoming_mails_bucket" {
  count = var.env == "live" ? 1 : 0
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    resources = ["${aws_s3_bucket.incoming_mails[0].arn}/*"]
  }
}

resource "aws_iam_policy" "send_emails" {
  count  = var.env == "live" ? 1 : 0
  name   = "${var.project_name}-${var.env}-send_emails"
  policy = data.aws_iam_policy_document.send_emails[0].json
}

data "aws_iam_policy_document" "send_emails" {
  count = var.env == "live" ? 1 : 0
  statement {
    actions = [
      "ses:SendEmail",
      "ses:SendRawEmail"
    ]

    resources = [
      aws_ses_domain_identity.this[0].arn,
      aws_ses_email_identity.recipient[0].arn
    ]
  }
}

resource "aws_cloudwatch_log_group" "lambda_logging" {
  count             = var.env == "live" ? 1 : 0
  name              = "/aws/lambda/${var.project_name}-${var.env}_mail-forwarder"
  retention_in_days = 7
}

resource "aws_iam_policy" "cloudwatch_logging" {
  count  = var.env == "live" ? 1 : 0
  name   = "${var.project_name}-${var.env}-cloudwatch-logging"
  policy = data.aws_iam_policy_document.cloudwatch_logging[0].json
}

data "aws_iam_policy_document" "cloudwatch_logging" {
  count = var.env == "live" ? 1 : 0
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_role_policy_attachment" "mail_forwarder_cloudwatch_logging" {
  count      = var.env == "live" ? 1 : 0
  role       = aws_iam_role.mail_forwarder[0].name
  policy_arn = aws_iam_policy.cloudwatch_logging[0].arn
}

output "mail_domain_validation_dkim_tokens" {
  value = var.env == "live" ? aws_ses_domain_dkim.this[0].dkim_tokens : []
}