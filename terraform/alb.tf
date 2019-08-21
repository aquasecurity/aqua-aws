#################################################
# Application Load Balancer for Console
#################################################
resource "aws_lb" "lb" {
  name                       = "${var.project}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = ["${aws_security_group.alb.id}"]
  subnets                    = ["${module.vpc.public_subnets}"]
  enable_deletion_protection = false

  tags = {
    Project   = "${var.project}"
    Name      = "${var.project}-alb"
    Terraform = "true"
  }
}

#################################################
# Listener
#################################################
resource "aws_lb_listener" "redirect" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.alb_http_port}"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "${var.alb_https_port}"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "console" {
  load_balancer_arn = "${aws_lb.lb.arn}"
  port              = "${var.alb_https_port}"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${aws_acm_certificate.cert.id}"

  default_action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.lb.arn}"
  }
}
