resource "aws_iam_role" "this" {
  name               = "${var.stack_name}_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.lambda-sts_policy.json
  tags = {
    Name = var.tags
  }
}

resource "aws_iam_role_policy" "this" {
  name   = "${var.stack_name}_lambda_policy"
  role   = aws_iam_role.this.id
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

  # CloudwatchLogsFullAccess
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
