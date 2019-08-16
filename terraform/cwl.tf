resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/${var.project}"
}

resource "aws_cloudwatch_log_group" "aquacsp-vpc" {
  name = "/vpc/${var.project}"
}

resource "aws_flow_log" "aquacsp-vpc" {
  iam_role_arn    = "${aws_iam_role.aquacsp-vpc.arn}"
  log_destination = "${aws_cloudwatch_log_group.aquacsp-vpc.arn}"
  traffic_type    = "ALL"
  vpc_id          = "${module.vpc.vpc_id}"
}
