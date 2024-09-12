terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
  backend "s3" {
    bucket = "metalblueberry"
    key    = "acnil-infrastructure"
    region = "eu-west-1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

resource "aws_iam_user" "github" {
  name = "github"
  path = "/acnil/"
}

resource "aws_iam_group" "acnil-bot" {
  name = "acnil-bot"
  path = "/acnil-bot/"
}

resource "aws_iam_user_group_membership" "acnil-bot-group-for-github-user" {
  user = aws_iam_user.github.name

  groups = [
    aws_iam_group.acnil-bot.name,
  ]
}

data "aws_iam_policy_document" "s3_terraform_state" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      "arn:aws:s3:::metalblueberry/*",
      "arn:aws:s3:::metalblueberry"
    ]
  }
}

resource "aws_iam_group_policy" "s3_terraform_state" {
  name   = "UpdateS3TerraformState"
  group  = aws_iam_group.acnil-bot.name
  policy = data.aws_iam_policy_document.s3_terraform_state.json
}

data "aws_iam_policy_document" "acnil-bot-lambda-full-access" {
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
      "arn:aws:lambda:eu-west-1:880190706950:function:*-acnil-bot",
      "arn:aws:lambda:eu-west-1:880190706950:function:*-audit-acnil-bot"
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

resource "aws_iam_group_policy" "acnil-bot-lambda-full-access" {
  name   = "AcnilBotLambda"
  group  = aws_iam_group.acnil-bot.name
  policy = data.aws_iam_policy_document.acnil-bot-lambda-full-access.json
}

data "aws_iam_policy_document" "events" {
  statement {
    effect = "Allow"
    actions = [
      "events:DeleteRule",
      "events:DescribeRule",
      "events:ListTagsForResource",
      "events:ListTargetsByRule",
      "events:PutRule",
      "events:PutTargets",
      "events:RemoveTargets",
    ]
    resources = [
      "arn:aws:events:eu-west-1:880190706950:rule/*-acnil-bot-daily_rule",
    ]
  }
}
resource "aws_iam_group_policy" "events" {
  name   = "Events"
  group  = aws_iam_group.acnil-bot.name
  policy = data.aws_iam_policy_document.events.json
}

data "aws_iam_policy_document" "misc" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:DeleteLogGroup",
      "logs:DeleteRetentionPolicy",
      "logs:DescribeLogGroups",
      "logs:ListTagsLogGroup",
      "logs:PutRetentionPolicy",
    ]
    resources = [
      "arn:aws:logs:eu-west-1:880190706950:log-group:/aws/lambda/*-acnil-bot*",
      "arn:aws:logs:eu-west-1:880190706950:log-group:/aws/lambda/default-acnil-bot:log-stream:"
    ]
  }
}

resource "aws_iam_group_policy" "misc" {
  name   = "Miscellaneous"
  group  = aws_iam_group.acnil-bot.name
  policy = data.aws_iam_policy_document.misc.json
}


data "aws_iam_policy_document" "acnil-bot-iam" {
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
      "arn:aws:iam::880190706950:role/*-acnil-bot",
      "arn:aws:iam::880190706950:policy/*-audit-acnil-bot-logs",
      "arn:aws:iam::880190706950:policy/*-acnil-bot-logs"
    ]
  }
}

resource "aws_iam_group_policy" "acnil-bot-iam" {
  name   = "AcnilBotIAM"
  group  = aws_iam_group.acnil-bot.name
  policy = data.aws_iam_policy_document.acnil-bot-iam.json
}
