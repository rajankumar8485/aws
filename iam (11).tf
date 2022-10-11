# For ph2-poc-ecs-task-role
resource "aws_iam_role" "task_role" {
  name               = "${var.stack_name}_role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  tags = {
    Name = var.tags
  }
}

resource "aws_iam_role_policy" "task_role_policy" {
  name   = "${var.stack_name}_role_policy"
  role   = aws_iam_role.task_role.id
  policy = data.aws_iam_policy_document.task_role_policy_document.json
}



data "aws_iam_policy_document" "task_role_policy_document" {
  # SecretManagerReadWrite
  statement {
    actions = [
      "secretsmanager:GetSecretValue",
      "kms:DescribeKey",
      "kms:ListAliases",
      "kms:ListKeys",
      "kms:Decrypt"
    ]
    effect = "Allow"
    resources = var.task_role_secret_settings[*].kms_key_arn
  }
  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:s3:::ph2-${var.stack_name}-public-*/*",
      "arn:aws:s3:::ph2-${var.stack_name}-private-*/*"
    ]
  }

  # CloudwatchLogsFullAccess
  statement {

    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogGroup",
      "logs:CreateLogStream"
    ]
    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.account_id}:${var.stack_name}*"
    ]

  }

  statement {
    actions = [
      "sqs:DeleteMessage",
      "sqs:GetQueueUrl",
      "sqs:ChangeMessageVisibility",
      "sqs:SendMessageBatch",
      "sqs:ReceiveMessage",
      "sqs:SendMessage",
      "sqs:GetQueueAttributes",
      "sqs:ListQueueTags",
      "sqs:ListDeadLetterSourceQueues",
      "sqs:DeleteMessageBatch",
      "sqs:PurgeQueue",
      "sqs:ChangeMessageVisibilityBatch",
      "sqs:SetQueueAttributes"
    ]
    resources = [
      "arn:aws:sqs:${var.aws_region}:${var.account_id}:${var.stack_name}*"
    ]
  }
}

# For ecsTaskExecutionRole
resource "aws_iam_role" "execution_role" {
  name               = "${var.execution_role_name}-${var.stack_name}"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  tags = {
    Name = var.tags
  }
}

resource "aws_iam_role_policy" "execution_role_policy" {
  name   = "${var.execution_role_name}_policy"
  role   = aws_iam_role.execution_role.id
  policy = data.aws_iam_policy_document.execution_role_policy_document.json

}

data "aws_iam_policy_document" "execution_role_policy_document" {
  dynamic "statement" {
    for_each = [ for secret in var.execution_role_secret_settings : secret.kms_key_arn ]
    content {
      effect = "Allow"
      actions = ["kms:Decrypt"]
      resources = [statement.value]
    }
  }
  dynamic "statement" {
    for_each = [ for secret in var.execution_role_secret_settings : secret.secret_arn ]
    content {
      effect = "Allow"
      actions = ["secretsmanager:GetSecretValue"]
      resources = [statement.value]
    }
  }
}

# For service role
resource "aws_iam_role" "service_role" {
  count              = length(var.names)
  name               = "${var.tags}-${var.names[count.index]}-service-role-${var.stack_name}" 
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json
  tags = {
    Name = var.tags
  }
}


resource "aws_iam_role_policy_attachment" "service_role_policy" {
  role       = aws_iam_role.service_role[count.index].id 
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_iam_policy_document" "service_role_policy_document" {
  statement {
    sid    = "ECSTaskManagement"
    effect = "Allow"
    actions = [
      "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
      "elasticloadbalancing:DeregisterTargets",
      "elasticloadbalancing:Describe*",
      "elasticloadbalancing:RegisterInstancesWithLoadBalancer",
      "elasticloadbalancing:RegisterTargets",
      "route53:ChangeResourceRecordSets",
      "route53:CreateHealthCheck",
      "route53:DeleteHealthCheck",
      "route53:Get*",
      "route53:List*",
      "route53:UpdateHealthCheck",
      "servicediscovery:DeregisterInstance",
      "servicediscovery:Get*",
      "servicediscovery:List*",
      "servicediscovery:RegisterInstance",
      "servicediscovery:UpdateInstanceCustomHealthStatus"
    ]
    resources = [
      "arn:aws:ecs:${var.aws_region}:${var.account_id}:cluster/${var.stack_name}"
    ]
  }
  statement {
    sid    = "AutoScaling"
    effect = "Allow"
    actions = [
      "autoscaling:Describe*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "AutoScalingManagement"
    effect = "Allow"
    actions = [
      "autoscaling:DeletePolicy",
      "autoscaling:PutScalingPolicy",
      "autoscaling:SetInstanceProtection",
      "autoscaling:UpdateAutoScalingGroup"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "AutoScalingPlanManagement"
    effect = "Allow"
    actions = [
      "autoscaling-plans:CreateScalingPlan",
      "autoscaling-plans:DeleteScalingPlan",
      "autoscaling-plans:DescribeScalingPlans"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "CWAlarmManagement"
    effect = "Allow"
    actions = [
      "cloudwatch:DeleteAlarms",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:PutMetricAlarm"
    ]
    resources = [
      "arn:aws:cloudwatch:*:*:alarm:*"
    ]
  }
  statement {
    sid    = "ECSTagging"
    effect = "Allow"
    actions = [
      "ec2:CreateTags"
    ]
    resources = [
      "arn:aws:ec2:*:*:network-interface/*"
    ]
  }
  statement {
    sid    = "CWLogGroupManagement"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DescribeLogGroups",
      "logs:PutRetentionPolicy"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/ecs/*"
    ]
  }
  statement {
    sid    = "CWLogStreamManagement"
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:*:*:log-group:/aws/ecs/*:log-stream:*"
    ]
  }
  statement {
    sid    = "ExecuteCommandSessionManagement"
    effect = "Allow"
    actions = [
      "ssm:DescribeSessions"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "ExecuteCommand"
    effect = "Allow"
    actions = [
      "ssm:StartSession"
    ]
    resources = [
      "arn:aws:ecs:*:*:task/*",
      "arn:aws:ssm:*:*:document/AmazonECS-ExecuteInteractiveCommand"
    ]
  }
}

# This assume role document is shared between both the task execution role and the task role.

data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  version = "2012-10-17"
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
