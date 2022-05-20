resource "aws_sns_topic" "user_signup" {
  name = "${var.project_name}-${var.env}-user_signup"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_subscription" {
  topic_arn            = aws_sns_topic.user_signup.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.user_signup.arn
  raw_message_delivery = true
}

resource "aws_sqs_queue" "user_signup" {
  name = "${var.project_name}-${var.env}-user_signup"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.user_signup_dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "user_signup_dlq" {
  name = "${var.project_name}-${var.env}-user_signup_dlq"
}

resource "aws_sqs_queue_policy" "user_signup_sns_to_sqs" {
  queue_url = aws_sqs_queue.user_signup.id
  policy    = data.aws_iam_policy_document.user_signup_sns_to_sqs.json
}

data "aws_iam_policy_document" "user_signup_sns_to_sqs" {
  statement {
    actions = [
      "SQS:SendMessage"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      aws_sqs_queue.user_signup.arn
    ]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"

      values = [
        aws_sns_topic.user_signup.arn
      ]
    }
  }
}

resource "aws_iam_user" "auth0" {
  name = "${var.project_name}-${var.env}-auth0"
}

resource "aws_iam_access_key" "auth0" {
  user = aws_iam_user.auth0.name
}

resource "aws_iam_user_policy_attachment" "auth0_sns_user_signup" {
  user       = aws_iam_user.auth0.name
  policy_arn = aws_iam_policy.sns_publish_user_signup.arn
}

resource "aws_iam_policy" "sns_publish_user_signup" {
  name   = "${var.project_name}-${var.env}-sns_publish_user_signup"
  policy = data.aws_iam_policy_document.sns_publish_user_signup.json
}

data "aws_iam_policy_document" "sns_publish_user_signup" {
  statement {
    actions = [
      "SNS:Publish"
    ]

    resources = [
      aws_sns_topic.user_signup.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ebs_read_write_sqs" {
  role       = var.ebs_iam_role_name
  policy_arn = aws_iam_policy.read_write_sqs.arn
}

resource "aws_iam_policy" "read_write_sqs" {
  name   = "${var.project_name}-${var.env}-read_write_sqs"
  policy = data.aws_iam_policy_document.read_write_sqs.json
}

data "aws_iam_policy_document" "read_write_sqs" {
  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "sqs:SendMessage"
    ]

    resources = [
      aws_sqs_queue.user_signup.arn,
      aws_sqs_queue.carvis_command.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ebs_read_sqs_dlq" {
  role       = var.ebs_iam_role_name
  policy_arn = aws_iam_policy.read_sqs_dlq.arn
}

resource "aws_iam_policy" "read_sqs_dlq" {
  name   = "${var.project_name}-${var.env}-read_sqs_dlq"
  policy = data.aws_iam_policy_document.read_sqs_dlq.json
}

data "aws_iam_policy_document" "read_sqs_dlq" {
  statement {
    actions = [
      "sqs:GetQueueAttributes",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
    ]

    resources = [
      aws_sqs_queue.user_signup_dlq.arn,
      aws_sqs_queue.carvis_command_dlq.arn
    ]
  }
}

resource "aws_iam_role_policy_attachment" "ebs_list_sqs" {
  role       = var.ebs_iam_role_name
  policy_arn = aws_iam_policy.list_sqs.arn
}

resource "aws_iam_policy" "list_sqs" {
  name   = "${var.project_name}-${var.env}-list_sqs"
  policy = data.aws_iam_policy_document.list_sqs.json
}

data "aws_iam_policy_document" "list_sqs" {
  statement {
    actions = [
      "sqs:ListQueues"
    ]

    resources = ["*"]
  }
}

resource "aws_sqs_queue" "carvis_command" {
  name = "${var.project_name}-${var.env}-carvis_command"
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.carvis_command_dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "carvis_command_dlq" {
  name = "${var.project_name}-${var.env}-carvis_command_dlq"
}
