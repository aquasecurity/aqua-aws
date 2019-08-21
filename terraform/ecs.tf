resource "aws_ecs_cluster" "cluster" {
  name = "${var.project}-cluster"

  tags = {
    Name      = "${var.project}-cluster"
    Terraform = "true"
    Owner     = "${var.resource_owner}"
  }
}

resource "aws_ecs_service" "console-service" {
  depends_on      = ["aws_iam_role.task_execution_role"]
  name            = "${var.project}-console-service"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.console-task-definition.arn}"
  desired_count   = 1
  iam_role        = "${data.aws_iam_role.service_role-ecs-service.arn}"

  load_balancer {
    target_group_arn = "${aws_lb_target_group.lb.arn}"
    container_name   = "aqua-server"
    container_port   = "${var.aqua_server_console_port}"
  }
}

resource "aws_ecs_service" "gateway-service" {
  depends_on      = ["aws_iam_role.task_execution_role"]
  name            = "${var.project}-gateway-service"
  cluster         = "${aws_ecs_cluster.cluster.id}"
  task_definition = "${aws_ecs_task_definition.gateway-task-definition.arn}"
  desired_count   = 1
}

resource "aws_ecs_task_definition" "console-task-definition" {
  family                = "${var.project}-console"
  container_definitions = "${data.template_file.console-service.rendered }"
  execution_role_arn    = "${aws_iam_role.task_execution_role.arn}"

  network_mode = "bridge"

  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }

  tags = {
    Name      = "${var.project}-console"
    Terraform = "true"
    Owner     = "${var.resource_owner}"
  }
}

resource "aws_ecs_task_definition" "gateway-task-definition" {
  depends_on            = ["aws_iam_role.task_execution_role"]
  family                = "${var.project}-gateway"
  container_definitions = "${data.template_file.gateway-service.rendered }"
  execution_role_arn    = "${aws_iam_role.task_execution_role.arn}"

  network_mode = "bridge"

  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }

  tags = {
    Name      = "${var.project}-gateway"
    Terraform = "true"
    Owner     = "${var.resource_owner}"
  }
}

data "template_file" "console-service" {
  depends_on = ["aws_ecs_task_definition.gateway-task-definition", "aws_ecs_service.gateway-service"]
  template   = "${file("task-definitions/console-service.tmpl.json")}"

  vars = {
    awslogs_group            = "/ecs/${var.project}"
    awslogs_region           = "${var.region}"
    aqua_server_console_port = "${var.aqua_server_console_port}"
    aqua_server_gateway_port = "${var.aqua_server_gateway_port}"
    admin_password           = "${var.secretsmanager_admin_password}"
    license_token            = "${var.secretsmanager_license_token}"
    db_hostname              = "${module.db.this_db_instance_address}"
    db_port                  = "${var.postgres_port}"
    db_username              = "${var.postgres_username}"
    db_password              = "${var.secretsmanager_db_password}"
    credentialsParameter     = "${data.aws_secretsmanager_secret.container_repository.arn}"
  }
}

data "template_file" "gateway-service" {
  template = "${file("task-definitions/gw-service.tmpl.json")}"

  vars = {
    awslogs_group        = "/ecs/${var.project}"
    awslogs_region       = "${var.region}"
    aqua_gateway_port    = "${var.aqua_gateway_port}"
    db_hostname          = "${module.db.this_db_instance_address}"
    db_port              = "${var.postgres_port}"
    db_username          = "${var.postgres_username}"
    db_password          = "${var.secretsmanager_db_password}"
    credentialsParameter = "${data.aws_secretsmanager_secret.container_repository.arn}"
    gateway_dns          = "${aws_elb.gw-elb.dns_name}:8443"
  }
}
