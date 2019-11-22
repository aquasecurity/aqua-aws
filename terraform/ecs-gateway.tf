resource "aws_ecs_cluster" "gateway-cluster" {
  name = "${var.project}-gateway-cluster"

  tags = {
    Name      = "${var.project}-gateway-cluster"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_ecs_service" "gateway-service" {
  depends_on      = [aws_iam_role.task-execution-role]
  name            = "${var.project}-gateway-service"
  cluster         = aws_ecs_cluster.gateway-cluster.id
  task_definition = aws_ecs_task_definition.gateway-task-definition.arn
  desired_count   = 1
  propagate_tags  = "TASK_DEFINITION"
  #Below is required for network_mode = "awsvpc" in task definition
  #network_configuration {
  #  subnets = module.vpc.public_subnets
  #}

  load_balancer {
    target_group_arn = aws_lb_target_group.nlb-microenforcer-target-group.arn
    container_name   = "aqua-gateway"
    container_port   = var.aqua_enforcer_port
  }


  tags = {
    Name      = "${var.project}-gateway"
    Terraform = "true"
    Owner     = var.resource_owner
  }

}

resource "aws_ecs_task_definition" "gateway-task-definition" {
  depends_on            = [aws_iam_role.task-execution-role]
  family                = "${var.project}-gateway"
  container_definitions = data.template_file.gateway-service.rendered
  execution_role_arn    = aws_iam_role.task-execution-role.arn

  #Line below required to use target type IP for NLB
  #network_mode = "awsvpc"
  network_mode = "bridge"

  volume {
    name      = "docker-socket"
    host_path = "/var/run/docker.sock"
  }

  tags = {
    Name      = "${var.project}-gateway"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

data "template_file" "gateway-service" {
  template = file("task-definitions/gateway-service.tmpl.json")

  vars = {
    registry_version     = var.aquacsp_registry
    gateway_memory_size  = var.gateway_memory_size_mb
    awslogs_group        = "/ecs/${var.project}"
    awslogs_region       = var.region
    aqua_enforcer_port   = var.aqua_enforcer_port
    db_hostname          = module.db.this_db_instance_address
    db_port              = var.postgres_port
    db_username          = var.postgres_username
    db_password          = var.secretsmanager_db_password
    credentialsParameter = data.aws_secretsmanager_secret.container_repository.arn
    enforcer_dns         = "${aws_lb.nlb-microenforcer.dns_name}:${var.aqua_enforcer_port}"
    #gateway_dns          = "${aws_alb.alb-gateway.dns_name}:${var.aqua_server_gateway_port}"
    gateway_dns = "${aws_lb.nlb-server.dns_name}:${var.aqua_server_gateway_port}"
  }
}