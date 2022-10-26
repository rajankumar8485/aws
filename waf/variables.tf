variable "stack_name" {
  type    = string
  default = "test"
}

# variable "aws_resource_arn" {
#   type    = string
#   default = ""
# }

variable "rules" {
  type    = any
  default = []
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to resources."
  default     = {}
}

variable "waf_type" {
  type        = list(string)
  description = "list of waf resource types."
  default     = ["public-api","device"]
}

variable "waf_association_map" {
  type        = list(map(string))
  description = "Map of waf association."
  default     = []
}