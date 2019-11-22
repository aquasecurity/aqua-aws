/*
 The aws_iam_instance_profile below is used in module "asg" for autoscaling
 EC2 instances. Instance Profiles require a role which is next...
 */
resource "aws_iam_instance_profile" "instance-profile-ecs-instance" {
  name = "${var.project}-ecs-instance_profile"
  role = aws_iam_role.instance-role-ecs-instance.name
}

/*
The aws_iam_role below is part of the instance profile above. It requires
the aws_iam_policy document below to assume roles...
*/
resource "aws_iam_role" "instance-role-ecs-instance" {
  name               = "${var.project}-ecs-instance-iam-role"
  assume_role_policy = data.aws_iam_policy_document.trust-policy-ecs-instance.json
}

data "aws_iam_policy_document" "trust-policy-ecs-instance" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

/*
The aws_iam_role_policy_attachment resources below assign policies to
the role above. In this case, AWS Managed policies for SSM and ECS are applied...
*/
resource "aws_iam_role_policy_attachment" "policy-attachment-ssm-ecs-instance" {
  role       = aws_iam_role.instance-role-ecs-instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "policy-attachment-ec2-container-service-ecs-instance" {
  role       = aws_iam_role.instance-role-ecs-instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

/*
This aws_iam_role_policy_attachment resource provides permission for
ECR scanning _in the AWS account_ that AQUA CSP is running in.
The modules/cross-acct-ecr folder contains the Terraform template
to run in target AWS ECR accounts to be scanned.
*/
resource "aws_iam_role_policy_attachment" "policy-attachment-ecr-instance" {
  role       = aws_iam_role.instance-role-ecs-instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#################################################
# ECS Service Role
#################################################

data "aws_iam_role" "service-role-ecs-service" {
  name = "AWSServiceRoleForECS"
}

#################################################
# ECS Task Execution Role
#################################################
data "aws_kms_alias" "secretsmanager" {
  name = "alias/aws/secretsmanager"
}

data "aws_iam_policy_document" "permission-policy-task-execution-role" {
  statement {
    sid = "1"

    actions = [
      "kms:Decrypt",
    ]

    resources = [
      data.aws_kms_alias.secretsmanager.arn,
    ]
  }

  statement {
    sid = "2"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.aws_secretsmanager_secret_version.container_repository.arn,
      data.aws_secretsmanager_secret_version.admin_password.arn,
      data.aws_secretsmanager_secret_version.db_password.arn,
      data.aws_secretsmanager_secret_version.license_token.arn,
    ]
  }

  statement {
    sid = "3"

    actions = [
      "ssm:GetParameters",
    ]

    resources = ["*"]
  }
}

data "aws_iam_policy_document" "task-execution-role-trust" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "task-execution-role" {
  name               = "${var.project}-task-execution-role"
  assume_role_policy = data.aws_iam_policy_document.task-execution-role-trust.json
}

resource "aws_iam_policy" "task-execution-role" {
  name   = "${var.project}-task-execution-role-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.permission-policy-task-execution-role.json
}

resource "aws_iam_role_policy_attachment" "policy-attachment-secretsmanager-task-execution-role" {
  role       = aws_iam_role.task-execution-role.name
  policy_arn = aws_iam_policy.task-execution-role.arn
}

resource "aws_iam_role_policy_attachment" "policy-attachment-amazon-ecs-task-execution-role-policy-task-execution-role" {
  role       = aws_iam_role.task-execution-role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

#################################################
# RDS Enchaned Monitoring
#################################################
resource "aws_iam_role" "rds-enhanced-monitoring" {
  name               = "${var.project}-rds-enhanced-monitoring"
  assume_role_policy = data.aws_iam_policy_document.trust-policy-rds-enhanced-monitoring.json
}

data "aws_iam_policy_document" "trust-policy-rds-enhanced-monitoring" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "policy-attachment-rds-enhanced-monitoring" {
  role       = aws_iam_role.rds-enhanced-monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}