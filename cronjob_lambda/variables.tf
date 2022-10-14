variable "stack_name" {
  description = "A name generated for the stack."
  type        = string
}

variable "lambda_handler" {
  type    = string
}

variable "lambda_runtime" {
  type    = string
  default = "python3.9"
}

variable "event_rule_description" {
  description = "Description for event rule"
  type        = string
}

variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to resources."
  default     = {}

}

variable "aws_region" {
  description = "Working region"
  type        = string
}
