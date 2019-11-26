#################################################
# Public ALB for Aqua Console
#################################################
resource "aws_alb" "alb-console" {
  name                       = "${var.project}-alb-console"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-console-sg.id]
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false

  tags = {
    Project   = var.project
    Name      = "${var.project}-alb"
    Terraform = "true"
  }
}

#################################################
# Public ALB Listeners for Aqua Console
#################################################
resource "aws_alb_listener" "redirect-console" {
  load_balancer_arn = aws_alb.alb-console.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = 443
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_alb_listener" "https-console" {
  load_balancer_arn = aws_alb.alb-console.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.cert.id

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-console-target-group.arn
  }
}

#################################################
# ALB Target Group for Aqua Console
#################################################
resource "aws_alb_target_group" "alb-console-target-group" {
  name                 = "${var.project}-alb-console-tg"
  port                 = var.aqua_server_console_port
  protocol             = "HTTP"
  deregistration_delay = 120
  vpc_id               = module.vpc.vpc_id
}