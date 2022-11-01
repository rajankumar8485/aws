variable "stack_name" {
  type    = string
  default = "test"
}

variable "mongoatlas_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_id" {
  type        = string
  description = "VPC cidr for aws private endpoint"
  default     = ""
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet id's for aws private endpoint"
  default     = []
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group id's for aws private endpoint"
  default     = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to resources."
  default     = {}
}