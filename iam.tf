resource "aws_iam_role" "this" {
  name               = var.lambda_role_name
  assume_role_policy = "${file("${path.module}/policies/lambda_sts_policy.json")}"
}

resource "aws_iam_policy" "this" {
  name = var.lambda_policy_name
  path = "/"

  policy = "${file("${path.module}/policies/lambda_policy.json")}"
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}