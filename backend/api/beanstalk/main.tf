resource "aws_elastic_beanstalk_application" "this" {
  name = var.project_name
}

resource "aws_elastic_beanstalk_environment" "this" {
  name                = "${var.project_name}-${var.env}"
  application         = aws_elastic_beanstalk_application.this.name
  solution_stack_name = "64bit Amazon Linux 2 v3.2.6 running Corretto 11"

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "IamInstanceProfile"
    value     = aws_iam_instance_profile.this.name
  }

  setting {
    namespace = "aws:autoscaling:launchconfiguration"
    name      = "InstanceType"
    value     = "t2.micro"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SERVER_PORT"
    value     = "5000"
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "SPRING_PROFILES_ACTIVE"
    value     = var.env
  }


  setting {
    namespace = "aws:elasticbeanstalk:application"
    name      = "Application Healthcheck URL"
    value     = "/actuator/health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:cloudwatch:logs"
    name      = "StreamLogs"
    value     = "true"
  }
}

resource "aws_iam_instance_profile" "this" {
  name = "${var.project_name}-${var.env}-ebs"
  role = aws_iam_role.this.name
}

resource "aws_iam_role" "this" {
  name               = "${var.project_name}-${var.env}-ebs"
  assume_role_policy = data.aws_iam_policy_document.this.json
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSElasticBeanstalkWebTier"
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

output "ebs_iam_role_name" {
  value = aws_iam_role.this.name
}
