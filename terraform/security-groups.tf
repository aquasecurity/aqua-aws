#################################################
# Public ALB for Aqua Console
#################################################
resource "aws_security_group" "alb-console-sg" {
  name        = "${var.project}-alb-console-sg"
  description = "External access to Aqua Console via ALB"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project}-alb-sg"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_security_group_rule" "http-ingress-alb" {
  type        = "ingress"
  description = "Ingress HTTP for External Application Load Balancer"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  # Remember, passing in a list of IP addresses to filter access to the console!
  cidr_blocks       = var.aqua_console_access
  security_group_id = aws_security_group.alb-console-sg.id
}

resource "aws_security_group_rule" "https-ingress-alb" {
  type        = "ingress"
  description = "Ingress HTTPS for External Application Load Balancer"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  # Remember, passing in a list of IP addresses to filter access to the console!
  cidr_blocks       = var.aqua_console_access
  security_group_id = aws_security_group.alb-console-sg.id
}

#################################################
# Internal ALB for Aqua Console from Gateway
#################################################
resource "aws_security_group" "alb-gateway-sg" {
  name        = "${var.project}-alb-gateway-sg"
  description = "Incoming gRPC Gateway Connections"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project}-alb-gateway-sg"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_security_group_rule" "gateway-ingress-alb" {
  type              = "ingress"
  description       = "Ingress HTTP for External Application Load Balancer"
  from_port         = var.aqua_server_gateway_port
  to_port           = var.aqua_server_gateway_port
  protocol          = "tcp"
  cidr_blocks       = var.vpc_private_subnets
  security_group_id = aws_security_group.alb-gateway-sg.id
}

#################################################
# EC2 Security Groups for Aqua Console
#################################################
resource "aws_security_group" "ec2-ecs-server-host" {
  name        = "${var.project}-ec2-server-sg"
  description = "${var.project}-ec2-server-sg"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project}-ec2-server-sg"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_security_group_rule" "console-ingress-ec2" {
  type                     = "ingress"
  description              = "Ingress to ECS EC2 Instance for Aqua Console"
  from_port                = var.aqua_server_console_port
  to_port                  = var.aqua_server_console_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb-console-sg.id
  security_group_id        = aws_security_group.ec2-ecs-server-host.id
}

resource "aws_security_group_rule" "gateway-ingress-ec2" {
  type              = "ingress"
  description       = "Ingress to ECS EC2 Instance for Gateway Service"
  from_port         = var.aqua_server_gateway_port
  to_port           = var.aqua_server_gateway_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.ec2-ecs-server-host.id
}


#################################################
# EC2 Security Groups for Aqua Gateway
#################################################
resource "aws_security_group" "ec2-ecs-gateway-host" {
  name        = "${var.project}-ec2-gateway-sg"
  description = "${var.project}-ec2-gateway-sg"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project}-ec2-gateway-sg"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_security_group_rule" "enforcer-ingress-ec2" {
  type              = "ingress"
  description       = "Ingress to ECS EC2 Instance for Enforcer Service"
  from_port         = var.aqua_enforcer_port
  to_port           = var.aqua_enforcer_port
  protocol          = "tcp"
  cidr_blocks       = [var.vpc_cidr]
  security_group_id = aws_security_group.ec2-ecs-gateway-host.id
}

resource "aws_security_group_rule" "enforcer-container-ingress-ec2" {
  type        = "ingress"
  description = "Ingress to ECS EC2 Instance from Console Docker container network for Enforcer Service"
  from_port   = var.aqua_enforcer_port
  to_port     = var.aqua_enforcer_port
  protocol    = "tcp"
  # Default Docker network CIDR
  cidr_blocks       = ["172.17.0.0/16"]
  security_group_id = aws_security_group.ec2-ecs-gateway-host.id
}

#################################################
# RDS
#################################################
resource "aws_security_group" "rds" {
  name        = "${var.project}-rds-sg"
  description = "${var.project}-rds-sg"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = {
    Name      = "${var.project}-rds-sg"
    Terraform = "true"
    Owner     = var.resource_owner
  }
}

resource "aws_security_group_rule" "postgres-console-ingress-rds" {
  type        = "ingress"
  description = "Ingress to RDS Instance from ECS EC2 Console Instance(s)"
  from_port   = var.postgres_port
  to_port     = var.postgres_port
  protocol    = "tcp"
  #Allow all connections from EC2 ECS hosts running Aqua CSP containers to RDS
  source_security_group_id = aws_security_group.ec2-ecs-server-host.id
  security_group_id        = aws_security_group.rds.id
}

resource "aws_security_group_rule" "postgres-gateway-ingress-rds" {
  type        = "ingress"
  description = "Ingress to RDS Instance from ECS EC2 Gateway Instance(s)"
  from_port   = var.postgres_port
  to_port     = var.postgres_port
  protocol    = "tcp"
  #Allow all connections from EC2 ECS hosts running Aqua CSP containers to RDS
  source_security_group_id = aws_security_group.ec2-ecs-gateway-host.id
  security_group_id        = aws_security_group.rds.id
}
