#################################################
# Classic Load Balancer for Aqua Gateway
#################################################

resource "aws_elb" "gw-elb" {
  name            = "${var.project}-aqua-gw-elb"
  subnets         = ["${element(module.vpc.private_subnets,0)}", "${element(module.vpc.private_subnets,1)}", "${element(module.vpc.private_subnets,2)}"]
  security_groups = ["${aws_security_group.ec2-gateway.id}"]

  internal = true

  listener {
    instance_port     = 8443
    instance_protocol = "tcp"
    lb_port           = 8443
    lb_protocol       = "tcp"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8443"
    interval            = 30
  }

  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 120

  tags = {
    Terraform = "true"
    Owner     = "${var.resource_owner}"
  }
}
