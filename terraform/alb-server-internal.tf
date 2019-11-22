#################################################
# Internal ALB for Aqua Console from Gateway
#################################################
resource "aws_alb" "alb-gateway" {
  name                       = "${var.project}-alb-gateway"
  internal                   = true
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb-gateway-sg.id]
  subnets                    = module.vpc.public_subnets
  enable_deletion_protection = false

  tags = {
    Project   = var.project
    Name      = "${var.project}-alb-gateway"
    Terraform = "true"
  }
}

#################################################
# Internal ALB Listener for Gateway
#################################################
resource "aws_alb_listener" "alb-gateway" {
  load_balancer_arn = aws_alb.alb-gateway.arn
  port              = var.aqua_server_gateway_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.cert.id

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-gateway-target-group.arn
  }
}

#####################################################
# Internal ALB Target Group for Gateway
#####################################################
resource "aws_alb_target_group" "alb-gateway-target-group" {
  depends_on           = [aws_alb.alb-gateway]
  name                 = "${var.project}-alb-gateway-tg"
  port                 = var.aqua_server_gateway_port
  protocol             = "HTTPS"
  deregistration_delay = 120
  vpc_id               = module.vpc.vpc_id
}