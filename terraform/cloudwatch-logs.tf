#################################################
# VPC Flow Logs
#################################################

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.project}"
}

# Since explicitly creating here, do not need "logs:CreateLogGroup" action in policy.
resource "aws_cloudwatch_log_group" "aquacsp-vpc" {
  name = "/vpc/${var.project}"
}

resource "aws_flow_log" "aquacsp-vpc" {
  iam_role_arn    = aws_iam_role.aquacsp-vpc.arn
  log_destination = aws_cloudwatch_log_group.aquacsp-vpc.arn
  traffic_type    = "ALL"
  vpc_id          = module.vpc.vpc_id
}

#################################################
# VPC Flow Logs Role
#################################################

resource "aws_iam_role" "aquacsp-vpc" {
  name = "${var.project}-VPC-Flow-Logs"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "vpc-flow-logs.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF


  tags = {
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_iam_role_policy" "aquacsp-vpc" {
  name = "${var.project}-VPC-Flow-Logs-Policy"
  role = aws_iam_role.aquacsp-vpc.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogGroups",
        "logs:DescribeLogStreams"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}