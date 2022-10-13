resource "aws_iam_role" "lambda_role" {
  name               = "${var.stack_name}_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda-sts_policy.json
  tags = var.tags
}

resource "aws_iam_role_policy" "lambda_role_policy" {
  name   = "${var.stack_name}_lambda_policy"
  role   = aws_iam_role.lambda_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup"
    ]
    effect = "Allow"
    resources = "arn:aws:logs:${var.aws_region}:${var.account_id}:*"
  }

# CloudwatchLogsAccess
  statement {

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:log-group:/aws/lambda/ScheduleBatchTriggerStaging:*"
    ]

  }
  
}

data "aws_iam_policy_document" "lambda-sts_policy" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}
