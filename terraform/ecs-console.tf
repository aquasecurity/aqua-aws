resource "aws_ecs_cluster" "server-cluster" {
  name = "${var.project}-server-cluster"

  tags = {
    Name      = "${var.project}-server-cluster"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_ecs_service" "console-service" {
  depends_on      = [aws_iam_role.task-execution-role]
  name            = "${var.project}-console-service"
  cluster         = aws_ecs_cluster.server-cluster.id
  task_definition = aws_ecs_task_definition.console-task-definition.arn
  desired_count   = 1
  propagate_tags  = "TASK_DEFINITION"
  #iam_role        = data.aws_iam_role.service-role-ecs-service.arn

  load_balancer {
    target_group_arn = aws_alb_target_group.alb-console-target-group.arn
    container_name   = "aqua-server"
    container_port   = var.aqua_server_console_port
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nlb-server-target-group.arn
    container_name   = "aqua-server"
    container_port   = var.aqua_server_gateway_port
  }

  /*
  load_balancer {
    target_group_arn = aws_alb_target_group.alb-gateway-target-group.arn
    container_name   = "aqua-server"
    container_port   = var.aqua_server_gateway_port
  }
 */

  tags = {
    Name      = "${var.project}-console"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_ecs_task_definition" "console-task-definition" {
  family                = "${var.project}-console"
  container_definitions = data.template_file.console-service.rendered
  execution_role_arn    = aws_iam_role.task-execution-role.arn

  network_mode = "bridge"

  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }

  tags = {
    Name      = "${var.project}-console"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

data "template_file" "console-service" {
  depends_on = [
    aws_ecs_task_definition.gateway-task-definition,
    aws_ecs_service.gateway-service,
  ]
  template = file("task-definitions/console-service.tmpl.json")

  vars = {
    registry_version         = var.aquacsp_registry
    console_memory_size      = var.console_memory_size_mb
    awslogs_group            = "/ecs/${var.project}"
    awslogs_region           = var.region
    aqua_server_console_port = var.aqua_server_console_port
    aqua_server_gateway_port = var.aqua_server_gateway_port
    admin_password           = var.secretsmanager_admin_password
    license_token            = var.secretsmanager_license_token
    db_hostname              = module.db.this_db_instance_address
    db_port                  = var.postgres_port
    db_username              = var.postgres_username
    db_password              = var.secretsmanager_db_password
    credentialsParameter     = data.aws_secretsmanager_secret.container_repository.arn
  }
}