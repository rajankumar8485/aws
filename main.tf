resource "aws_lambda_function" "this" {
  filename         = file("${path.module}/artifacts/lambda.zip")
  function_name    = var.lambda_name
  role             = aws_iam_role.this.arn
  handler          = var.lambda_handler
  runtime          = var.lambda_runtime
  source_code_hash = filebase64sha256("${file("${path.module}/artifacts/lambda.zip")}")
}

resource "aws_cloudwatch_event_rule" "this" {
  name                = var.event_rule_name
  description         = var.event_rule_description
  schedule_expression = "rate(8 hours)"
}

resource "aws_cloudwatch_event_target" "this" {
  arn  = aws_lambda_function.this.arn
  rule = aws_cloudwatch_event_rule.this.name
}

resource "aws_lambda_permission" "this" {

  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.this.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn

}