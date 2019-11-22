data "aws_iam_policy" "AmazonEC2ContainerRegistryReadOnly" {
  arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_iam_policy_document" "trust-policy-ecr-role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.aqua_account_id}:root"]
    }

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

  }
}

resource "aws_iam_role" "ecr-role" {
  name               = "${var.aquascp_role_name}"
  assume_role_policy = "${data.aws_iam_policy_document.trust-policy-ecr-role.json}"
}

resource "aws_iam_policy_attachment" "ecr-policy-attach" {
  name       = "${var.aquascp_role_policy_name}"
  roles      = ["${aws_iam_role.ecr-role.name}"]
  policy_arn = "${data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn}"
}