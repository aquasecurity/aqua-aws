variable "region" {
  description = "Your region"
  default     = ""
}

variable "aqua_account_id" {
  description = "The AWS account ID in which Aqua CSP is installed in."
  default     = ""
}
variable "aquascp_role_name" {
  description = "Descriptive name that clearly states what service the role is for."
  default     = ""
}

variable "aquascp_role_policy_name" {
  description = "Descriptive name that clearly states what the policy attachment is for."
  default     = ""
}