data "aws_ami" "ecs-optimized" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  owners = ["591542846629"]
}

data "template_file" "userdata" {
  template = "${file("userdata/userdata.tmpl.sh")}"

  vars {
    cluster_name = "${var.project}-cluster"
  }
}

module "asg" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 2.0"

  name = "service"

  # Launch configuration
  lc_name = "${var.project}-ecs-lc"

  image_id        = "${data.aws_ami.ecs-optimized.image_id}"
  instance_type   = "${var.instance_type}"
  security_groups = ["${aws_security_group.ec2.id}", "${aws_security_group.ec2-gateway.id}"]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name          = "${var.project}-ecs-asg"
  target_group_arns = ["${aws_lb_target_group.lb.arn}"]

  # Only a single load balancer can be attached to an ECS service at once.
  # Aqua CSP has the console and gateway containers linked so must use ELB Classic.
  load_balancers = ["${aws_elb.gw-elb.name}"]

  vpc_zone_identifier       = "${module.vpc.public_subnets}"
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  user_data                 = "${data.template_file.userdata.rendered}"
  ebs_optimized             = true
  iam_instance_profile      = "${aws_iam_instance_profile.instance_profile-ecs_instance.name}"
  key_name                  = "${var.ssh-key_name}"

  tags = [
    {
      key                 = "Name"
      value               = "${var.project}-ecs-asg-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = "${var.resource_owner}"
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = "${var.project}"
      propagate_at_launch = true
    },
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
  ]
}
