// https://www.terraform.io/docs/providers/aws/d/iam_policy_document.html
//  assume_role_policy = <<EOF
//{
//  "Version": "2008-10-17",
//  "Statement": [
//    {
//      "Effect": "Allow"
//      "Principal": {
//        "Service": "ecs.amazonaws.com"
//      "Action": "sts:AssumeRole",
//      },
//    }
//  ]
//}
//EOF

// the aws_iam_policy_document data resource serializes as a standard JSON policy document
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
