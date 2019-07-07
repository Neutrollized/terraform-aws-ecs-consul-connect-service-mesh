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
