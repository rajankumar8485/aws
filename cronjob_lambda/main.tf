resource "aws_lambda_function" "lambda_function" {
  filename         = file("${path.module}/lambda.zip")
  function_name    = "${var.stack_name}_lambda"
  role             = aws_iam_role.lambda_role.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256("${file("${path.module}/lambda.zip")}")
  tags = var.tags
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name                = "${var.stack_name}_lambda_event_rule"
  description         = "${var.stack_name}-${var.event_rule_description}"
  schedule_expression = "rate(8 hours)"
}
 
resource "aws_cloudwatch_event_target" "event_target" {
  arn  = aws_lambda_function.lambda_function.arn
  rule = aws_cloudwatch_event_rule.event_rule.name
}

resource "aws_lambda_permission" "lambda_permission" {

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.event_rule.arn

}