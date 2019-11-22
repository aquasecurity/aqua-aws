
#################################################
# Network Load Balancer for Microenforcer
#################################################
resource "aws_lb" "nlb-microenforcer" {
  name               = "${var.project}-nlb-microenforcer"
  internal           = true
  load_balancer_type = "network"
  # Yo, word to you mother. Can't put security groups on NLBs yo!
  #security_groups                  = [aws_security_group.ec2-microenforcer.id]
  subnets                          = module.vpc.private_subnets
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false

  tags = {
    Project   = var.project
    Name      = "${var.project}-nlb-microenforcer"
    Terraform = "true"
  }
}

#################################################
# Network Load Balancer Listener
#################################################
resource "aws_lb_listener" "nlb-microenforcer" {
  load_balancer_arn = aws_lb.nlb-microenforcer.arn
  port              = var.aqua_enforcer_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb-microenforcer-target-group.arn
  }
}

#################################################
# Network Load Balancer Target Group
#################################################
resource "aws_lb_target_group" "nlb-microenforcer-target-group" {
  depends_on           = [aws_lb.nlb-microenforcer]
  name                 = "${var.project}-nlb-microenforcer-tg"
  port                 = var.aqua_enforcer_port
  protocol             = "TCP"
  deregistration_delay = 120
  #If use "ip" ECS must be set to host.
  #target_type          = "ip"
  vpc_id = module.vpc.vpc_id
}
