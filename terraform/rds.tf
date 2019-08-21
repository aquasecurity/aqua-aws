module "db" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 1.0"

  identifier        = "${var.project}-rds"
  engine            = "postgres"
  engine_version    = "9.6.11"
  instance_class    = "${var.db_instance_type}"
  allocated_storage = 30

  name                   = "${var.project}"
  username               = "${var.postgres_username}"
  password               = "${data.aws_secretsmanager_secret_version.db_password.secret_string}"
  port                   = "${var.postgres_port}"
  vpc_security_group_ids = ["${aws_security_group.rds.id}"]
  maintenance_window     = "Fri:17:00-Fri:17:30"
  backup_window          = "16:00-16:30"
  monitoring_interval    = "30"
  monitoring_role_name   = "${var.project}_monitoring_role"
  create_monitoring_role = true
  subnet_ids             = "${module.vpc.private_subnets}"

  # Aqua CSP requirements as of 4.2:
  # PostgreSQL 9.5 or 9.6, with a minimum storage size of 30 GB
  # https://docs.aquasec.com/docs/system-requirements
  allow_major_version_upgrade = false

  family                     = "postgres9.6"
  major_engine_version       = "9.6"
  final_snapshot_identifier  = "${var.project}"
  deletion_protection        = "${var.rds_delete_protect}"
  auto_minor_version_upgrade = true
  backup_retention_period    = "0"
  multi_az                   = "${var.multple_az}"
  copy_tags_to_snapshot      = true
  skip_final_snapshot        = true

  tags = {
    Project   = "${var.project}"
    Terraform = "true"
    Owner     = "${var.resource_owner}"
  }
}
