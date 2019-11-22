/*
This ARN value is required to for Aqua CSP ECR configuration at:
System -> Integrations

In the Aqua CSP interface, add a new ECR registry or modify an
existing one and put the ARN below
into the Access Delegation field.
*/

output "ecr_role_arn" {
  value = "${aws_iam_role.ecr-role.arn}"
}