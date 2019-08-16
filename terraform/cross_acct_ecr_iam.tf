# This policy allows AWS Cross Account ECR scanning.
resource "aws_iam_role_policy" "assume_role" {
  name = "allow-assume-role"
  role = "${aws_iam_role.instance_role-ecs_instance.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

/*

If you need cross account ECR scanning, you'll need to add the following
Terraform code and resources to your target AWS accounts. Don't add
this to the AWS account that Aqua CSP is running in!

#############
variables.tf
#############

variable "region" {
  default = "ap-northeast-1"
}

variable "aqua_account_id" {
  description = "The AWS account in which Aqua CSP is installed on."
  default     = "XXXXXXXXX"
}
variable "aquascp_role_name" {
  description = "Descriptive name that clearly states what service the role is for."
  default     = "aquacsp-cross-acct-ecr-assume-role"
}

variable "aquascp_role_policy_name" {
  description = "Descriptive name that clearly states what the policy attachment is for."
  default     = "aquacsp-cross-acct-ecr-assume-role-policy"
}

#############
main.tf
#############

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

*/

