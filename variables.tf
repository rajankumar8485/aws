variable "stack_name" {
  type    = string
  default = ""
}

variable "lambda_handler" {
  type    = string
  default = "lambda_handler"
}

variable "lambda_runtime" {
  type    = string
  default = "python3.8"
}

variable "event_rule_description" {
  type    = string
  default = "Event rule"
}

variable "aws_region" {
  type    = string
  default = ""
}

variable "account_id" {
  type    = number
  default = ""
}

variable "tags" {
  type    = string
  default = ""
}