variable "stack_name" {
  type    = string
  default = "test"
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

variable "waf_visibility_config" {
  description = "visibility config rule"

  type        = map(string)
  default     = {}
}