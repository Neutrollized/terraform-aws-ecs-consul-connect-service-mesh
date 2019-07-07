resource "aws_iam_instance_profile" "ec2_instance_profile" {
  role = "${aws_iam_role.ec2_role}"
  path = "/"
}

#------------------------
# Autoscaling role
#------------------------
// the aws_iam_policy_document data resource serializes as a standard JSON policy document
data "aws_iam_policy_document" "as_assume_role_policy_doc" {
  statement {
    effect = "allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["application-autoscaling.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "as_role" {
  assume_role_policy = "${data.aws_iam_policy_document.as_assume_role_policy_doc.json}"
  path               = "/"
}

data "aws_iam_policy_document" "as_policy_doc" {
  statement {
    effect = "allow"

    actions = [
      "application-autoscaling",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm",
      "ecs:DescribeServices",
      "ecs:UpdateService",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "as_policy" {
  name   = "service-autoscaling"
  policy = "{data.aws_iam_policy_document.as_policy_doc.json}"
}

#------------------------
# EC2 role
#------------------------
data "aws_iam_policy_document" "ec2_assume_role_policy_doc" {
  statement {
    effect = "allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  assume_role_policy = "${data.aws_iam_policy_document.ec2_assume_role_policy_doc.json}"
  path               = "/"
}

data "aws_iam_policy_document" "ec2_policy_doc" {
  statement {
    effect = "allow"

    actions = [
      "ecs:CreateCluster",
      "ecs:DeregisterContainerInstance",
      "ecs:DiscoverPollEndpoint",
      "ecs:Poll",
      "ecs:RegisterContainerInstance",
      "ecs:StartTelemetrySession",
      "ecs:Submit*",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "ecr:GetAuthorizationToken",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ec2_policy" {
  //typo?  should it be ec2-service?
  name = "ecs-service"

  policy = "{data.aws_iam_policy_document.ec2_policy_doc.json}"
}

#------------------------
# ECS role
#------------------------
data "aws_iam_policy_document" "ecs_assume_role_policy_doc" {
  statement {
    effect = "allow"

    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  assume_role_policy = "${data.aws_iam_policy_document.ecs_assume_role_policy_doc.json}"
  path               = "/"
}

data "aws_iam_policy_document" "ecs_policy_doc" {
  statement {
    effect = "allow"

    actions = [
      "ec2:AttachNetworkInterface",
      "ec2:CreateNetworkInterface",
      "ec2:CreateNetworkInterfacePermission",
      "ec2:DeleteNetworkInterface",
      "ec2:DeleteNetworkInterfacePermission",
      "ec2:Describe*",
      "ec2:DetachNetworkInterface",
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_policy" {
  name   = "ecs-service"
  policy = "{data.aws_iam_policy_document.ecs_policy_doc.json}"
}
