#################################################
# Aqua CSP Project - INPUT REQUIRED
#################################################
region = "Your Target Region"
resource_owner = "Your Name"
project = "aquacsp"

#################################################
# DNS Configuration - INPUT REQUIRED
# You must have already configured a domain name
# and hosted Zone in Route 53 for this to work!!!
#################################################
dns_domain= "example.com"
console_name = "aqua"

###################################################
# Security Group Configuration - INPUT REQUIRED
# Avoid leaving the Aqua CSP open to the world!!!
###################################################
aqua_console_access = "0.0.0.0/0"

#################################################
# VPC Configuration - OPTIONAL INPUT REQUIRED
# CIDR values are just for reference. You'll
# need to use values that won't overlap with
# other VPC CIDR values.
#################################################
vpc_cidr = "10.50.0.0/16"
vpc_public_subnets = ["10.50.1.0/24", "10.50.2.0/24", "10.50.3.0/24"]
vpc_private_subnets = ["10.50.11.0/28", "10.50.12.0/28", "10.50.13.0/28"]
# The AZs below are an example for the Tokyo Region.
vpc_azs = ["ap-northeast-1a", "ap-northeast-1c", "ap-northeast-1d"]


#################################################
# Secrets Manager Configuration
# These must be prepared in advance!!!
#################################################
secretsmanager_container_repository = "aqua/container_repository"
secretsmanager_admin_password = "aqua/admin_password"
secretsmanager_license_token = "aqua/license_token"
secretsmanager_db_password = "aqua/db_password"

#################################################
# EC2 Configuration - INPUT REQUIRED
#################################################
ssh-key_name = "Your AWS Key Pair Name"
instance_type = "m5.large"

#################################################
# RDS Configuration - OPTIONAL INPUT REQUIRED
# These settings are mainly for testing. If you
# want this in production, make sure to use 
# multi-az and delete protection. Also, go into
# rds.tf and adjust the backup schedule as well
# as snapshot retention, etc.
#################################################
db_instance_type = "db.t2.large"
postgres_username = "postgres"
postgres_port = "5432"
multple_az = false
rds_delete_protect = false

#################################################
# AQUA Ports
#################################################
aqua_server_console_port = "8080"
aqua_server_gateway_port = "8443"
aqua_gateway_port = "3622"
# Note that port 80 is redirected to 443
alb_http_port    = "80"
alb_https_port   = "443"