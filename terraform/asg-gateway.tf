data "aws_ami" "ecs-gateway-optimized" {
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

data "template_file" "gateway-userdata" {
  template = file("userdata/userdata.tmpl.sh")

  vars = {
    #cluster_name = "${var.project}-cluster"
    cluster_name = aws_ecs_cluster.gateway-cluster.name
  }
}

module "asg-gateway" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "~> 3.0"

  name = "gateway-service"

  # Launch configuration
  lc_name = "${var.project}-ecs-lc"

  image_id      = data.aws_ami.ecs-gateway-optimized.image_id
  instance_type = var.instance_type
  # This is an important setting. Open console, gateway, and enforcer ports on EC2 ECS host!
  security_groups = [aws_security_group.ec2-ecs-gateway-host.id]

  root_block_device = [
    {
      volume_size = "50"
      volume_type = "gp2"
    },
  ]

  # Auto scaling group
  asg_name = "${var.project}-ecs-gateway-asg"

  # This is important:
  # https://aws.amazon.com/premiumsupport/knowledge-center/ecs-register-container-instance-subnet/
  associate_public_ip_address = false
  target_group_arns           = [aws_lb_target_group.nlb-microenforcer-target-group.arn]

  vpc_zone_identifier       = module.vpc.private_subnets
  health_check_type         = "EC2"
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  user_data                 = data.template_file.gateway-userdata.rendered
  ebs_optimized             = true
  iam_instance_profile      = aws_iam_instance_profile.instance-profile-ecs-instance.name
  key_name                  = var.ssh-key_name

  tags = [
    {
      key                 = "Name"
      value               = "${var.project}-ecs-asg-gateway-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Owner"
      value               = var.resource_owner
      propagate_at_launch = true
    },
    {
      key                 = "Project"
      value               = var.project
      propagate_at_launch = true
    },
    {
      key                 = "Terraform"
      value               = "true"
      propagate_at_launch = true
    },
  ]
}