variable "stack_name" {
  description = "A name generated for the stack."
  type    = string
  default = ""
}

variable "lambda_handler" {
  type    = string
  default = ""
}

variable "lambda_runtime" {
  type    = string
  default = "python 3.9"
}

variable "event_rule_description" {
  description = "Description for event rule"
  type    = string
  default = ""
}

variable tags {
  default     = {}
  description = "A map of tags to apply to resources."
  type        = map(string)
}

variable "aws_region" {
  description = "Working region"
  type        = string
  }

variable "account_id" {
  description = "The aws region to use."
  type        = string
} 
