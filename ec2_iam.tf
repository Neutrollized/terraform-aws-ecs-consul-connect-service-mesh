resource "aws_iam_instance_profile" "ec2_instance_profile" {
  role = "${aws_iam_role.ec2_role}"
  path = "/"
}

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
  name   = "ecs-service"

  policy = "{data.aws_iam_policy_document.ec2_policy_doc.json}"
}
