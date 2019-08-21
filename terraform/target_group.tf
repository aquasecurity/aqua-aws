#################################################
# Target Group for Aqua Server (i.e. Console)
#################################################
resource "aws_lb_target_group" "lb" {
  name                 = "${var.project}-lb-console-tg"
  port                 = "${var.aqua_server_console_port}"
  protocol             = "HTTP"
  deregistration_delay = 120
  vpc_id               = "${module.vpc.vpc_id}"
}
