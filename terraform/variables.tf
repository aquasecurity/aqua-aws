variable "region" {
  default     = ""
  description = "Make sure you are running this in the intended region."
}

variable "resource_owner" {
  default     = ""
  description = "This will be used for tagging."
}

variable "project" {
  default     = ""
  description = "This will be used for naming resources."
}

variable "dns_domain" {
  default     = ""
  description = "Your preregistered domain name configured in Route 53."
}

variable "console_name" {
  default     = ""
  description = "The host name for the console. (i.e. https://aqua.example.com)"
}

variable "aqua_console_access" {
  default     = ""
  description = "Use 0.0.0.0/0 at your own peril."
}

variable "vpc_cidr" {
  default     = ""
  description = "CIDR for your Aqua CSP VPC."
}

variable "vpc_public_subnets" {
  default = [""]
}

variable "vpc_private_subnets" {
  default = [""]
}

variable "vpc_azs" {
  default = [""]
}

variable "secretsmanager_container_repository" {
  default     = ""
  description = "Preconfigured credentials in AWS SSM that store your my.aquasec.com login."
}

variable "secretsmanager_admin_password" {
  default     = ""
  description = "Preconfigured administrator password in AWS SSM for accessing the Aqua CSP console."
}

variable "secretsmanager_license_token" {
  default     = ""
  description = "Preconfigred license token in AWS SSM that you got from my.aquasec.com."
}

variable "secretsmanager_db_password" {
  default     = ""
  description = "Preconfigured AWS RDS PostgreSQL password in AWS SSM."
}

variable "ssh-key_name" {
  default     = ""
  type        = "string"
  description = "Required key pair to launch the ECS instance."
}

variable "instance_type" {
  default     = ""
  description = "ECS instance size."
}

variable "db_instance_type" {
  default     = ""
  description = "RDS instance size."
}

variable "postgres_username" {
  default     = ""
  description = "AWS RDS PostgreSQL database username."
}

variable "postgres_port" {
  default     = ""
  description = "AWS RDS PostgreSQL port. Keep the default unless you know what you're doing."
}

variable "multple_az" {
  default     = ""
  description = "Set this to true for production environments."
}

variable "rds_delete_protect" {
  default     = ""
  description = "Set this to true for production environments."
}

variable "aqua_server_console_port" {
  default     = ""
  description = "TCP port to access the Aqua CSP console from the AWS ALB."
}

variable "aqua_server_gateway_port" {
  default     = ""
  description = "TCP port incoming for enforcers from the AWS ELB."
}

variable "aqua_gateway_port" {
  default     = ""
  description = "Required port for incoming enforcers."
}

variable "alb_http_port" {
  default     = ""
  description = "External ALB for HTTP but the ALB will redirect to HTTPS."
}

variable "alb_https_port" {
  default     = ""
  description = "External ALB for HTTPS."
}
