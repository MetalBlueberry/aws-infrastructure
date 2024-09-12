resource "aws_iam_user" "interview-bot" {
  name = "interview-bot"
  path = "/interview-bot/"
}

resource "aws_iam_group" "interview-group-bot" {
  name = "interview-bot-group"
  path = "/interview-bot-group/"
}

resource "aws_iam_user_group_membership" "interview-bot-group-for-github-user" {
  user = aws_iam_user.interview-bot.name

  groups = [
    aws_iam_group.interview-group-bot.name,
  ]
}

resource "aws_iam_group_policy" "interview-bot-s3_terraform_state" {
  name   = "UpdateS3TerraformState"
  group  = aws_iam_group.interview-group-bot.name
  policy = data.aws_iam_policy_document.s3_terraform_state.json
}


data "aws_iam_policy_document" "interview-bot-lambda-full-access" {
  statement {
    effect = "Allow"
    actions = [
      "cloudformation:DescribeStacks",
      "cloudformation:ListStackResources",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs",
      "kms:ListAliases",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:GetRolePolicy",
      "iam:ListAttachedRolePolicies",
      "iam:ListRolePolicies",
      "iam:ListRoles",
      "lambda:*",
      "logs:DescribeLogGroups",
      "states:DescribeStateMachine",
      "states:ListStateMachines",
      "tag:GetResources",
      "xray:GetTraceSummaries",
      "xray:BatchGetTraces",
    ]
    resources = [
      "arn:aws:logs:eu-west-1:880190706950:log-group::log-stream:",
      "arn:aws:lambda:eu-west-1:880190706950:function:*-interview-bot",
    ]
  }
  statement {
    effect    = "Allow"
    actions   = ["iam:PassRole"]
    resources = ["*"]
    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["lambda.amazonaws.com"]
    }
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogStreams",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["arn:aws:logs:eu-west-1:880190706950:log-group:/aws/lambda/*"]
  }
}

resource "aws_iam_group_policy" "interview-bot-lambda-full-access" {
  name   = "InterviewBotLambda"
  group  = aws_iam_group.interview-group-bot.name
  policy = data.aws_iam_policy_document.interview-bot-lambda-full-access.json
}

data "aws_iam_policy_document" "interview-bot-logs" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DeleteRetentionPolicy",
      "logs:DescribeLogGroups",
      "logs:ListTagsLogGroup",
      "logs:PutRetentionPolicy",
      "logs:ListTagsForResource",
    ]
    resources = [
      "arn:aws:logs:eu-west-1:880190706950:log-group:/aws/lambda/*-interview-bot*",
      "arn:aws:logs:eu-west-1:880190706950:log-group:/aws/lambda/default-interview-bot:log-stream:"
    ]
  }
}

resource "aws_iam_group_policy" "interview-bot-logs" {
  name   = "Miscellaneous"
  group  = aws_iam_group.interview-group-bot.name
  policy = data.aws_iam_policy_document.interview-bot-logs.json
}


data "aws_iam_policy_document" "interview-bot-iam" {
  statement {
    effect = "Allow"
    actions = [
      "iam:AttachRolePolicy",
      "iam:CreatePolicy",
      "iam:CreateRole",
      "iam:DeletePolicy",
      "iam:DeleteRole",
      "iam:DetachRolePolicy",
      "iam:GetPolicy",
      "iam:GetPolicyVersion",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:ListInstanceProfilesForRole",
      "iam:ListPolicyVersions",
      "iam:ListRolePolicies",
      "iam:PassRole",
    ]
    resources = [
      "arn:aws:iam::880190706950:role/*-interview-bot",
      "arn:aws:iam::880190706950:policy/*-interview-bot-logs"
    ]
  }
}

resource "aws_iam_group_policy" "interview-bot-iam" {
  name   = "InterviewBotIAM"
  group  = aws_iam_group.interview-group-bot.name
  policy = data.aws_iam_policy_document.interview-bot-iam.json
}
