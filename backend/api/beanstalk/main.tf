resource "aws_elastic_beanstalk_application" "this" {
  name = var.project_name
}

resource "aws_elastic_beanstalk_environment" "this" {
  count               = var.env == "dev" ? 0 : 1
  name                = "${var.project_name}-${var.env}"
  application         = aws_elastic_beanstalk_application.this.name
  solution_stack_name = "64bit Amazon Linux 2 v3.3.1 running Corretto 11"

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
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AUTH_CLIENT_ID"
    value     = var.auth_client_id
  }

  setting {
    namespace = "aws:elasticbeanstalk:application:environment"
    name      = "AUTH_CLIENT_SECRET"
    value     = var.auth_client_secret
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

  setting {
    namespace = "aws:elb:listener:80"
    name      = "ListenerEnabled"
    value     = "false"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "ListenerProtocol"
    value     = "HTTPS"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "InstancePort"
    value     = "80"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "InstanceProtocol"
    value     = "HTTP"
  }

  setting {
    namespace = "aws:elb:listener:443"
    name      = "SSLCertificateId"
    value     = var.certificate_id
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateEnabled"
    value     = "true"
  }

  setting {
    namespace = "aws:autoscaling:updatepolicy:rollingupdate"
    name      = "RollingUpdateType"
    value     = "Health"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "DeploymentPolicy"
    value     = "RollingWithAdditionalBatch"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSizeType"
    value     = "Percentage"
  }

  setting {
    namespace = "aws:elasticbeanstalk:command"
    name      = "BatchSize"
    value     = "100"
  }

  setting {
    namespace = "aws:elasticbeanstalk:healthreporting:system"
    name      = "ConfigDocument"
    value     = "{\"Version\":1,\"CloudWatchMetrics\":{\"Instance\":{\"RootFilesystemUtil\":null,\"CPUIrq\":null,\"LoadAverage5min\":null,\"ApplicationRequests5xx\":null,\"ApplicationRequests4xx\":null,\"CPUUser\":null,\"LoadAverage1min\":null,\"ApplicationLatencyP50\":null,\"CPUIdle\":null,\"InstanceHealth\":null,\"ApplicationLatencyP95\":null,\"ApplicationLatencyP85\":null,\"ApplicationLatencyP90\":null,\"CPUSystem\":null,\"ApplicationLatencyP75\":null,\"CPUSoftirq\":null,\"ApplicationLatencyP10\":null,\"ApplicationLatencyP99\":null,\"ApplicationRequestsTotal\":null,\"ApplicationLatencyP99.9\":null,\"ApplicationRequests3xx\":null,\"ApplicationRequests2xx\":null,\"CPUIowait\":null,\"CPUNice\":null},\"Environment\":{\"InstancesSevere\":null,\"InstancesDegraded\":null,\"ApplicationRequests5xx\":null,\"ApplicationRequests4xx\":null,\"ApplicationLatencyP50\":null,\"ApplicationLatencyP95\":null,\"ApplicationLatencyP85\":null,\"InstancesUnknown\":null,\"ApplicationLatencyP90\":null,\"InstancesInfo\":null,\"InstancesPending\":null,\"ApplicationLatencyP75\":null,\"ApplicationLatencyP10\":null,\"ApplicationLatencyP99\":null,\"ApplicationRequestsTotal\":null,\"InstancesNoData\":null,\"ApplicationLatencyP99.9\":null,\"ApplicationRequests3xx\":null,\"ApplicationRequests2xx\":null,\"InstancesOk\":null,\"InstancesWarning\":null}},\"Rules\":{\"Environment\":{\"ELB\":{\"ELBRequests4xx\":{\"Enabled\":true}},\"Application\":{\"ApplicationRequests4xx\":{\"Enabled\":false}}}}}"
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

output "ebs_cname" {
  value = var.env == "dev" ? "dummy" : aws_elastic_beanstalk_environment.this[0].cname
}
