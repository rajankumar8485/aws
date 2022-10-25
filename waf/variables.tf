variable "stack_name" {
  type    = string
  default = "test"
}

variable "aws_resource_arn" {
  type    = string
  default = ""
}

variable "rules" {
  type    = any
  default = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to resources."
  default     = {}
}