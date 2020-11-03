resource "aws_iam_user" "ci_user" {
  name = "${module.labels.id}-ci"
  tags = module.labels.tags
}

resource "aws_iam_user_policy_attachment" "ci_user_ecr" {
  user       = aws_iam_user.ci_user.name
  policy_arn = var.iam_policy_container_registry_full_access
}

data "aws_iam_policy_document" "ci_user" {
  statement {
    actions = [
      "ecs:UpdateService",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:DescribeServices",
      "cloudwatch:PutDashboard",
      "cloudwatch:GetDashboard"
    ]

    resources = [
      "*",
    ]
  }
}

data "aws_iam_policy_document" "ci_user_lambda" {
  statement {
    actions = [
      "lambda:UpdateFunctionCode",
      "lambda:ListAliases",
      "lambda:ListVersionsByFunction",
      "lambda:UpdateAlias"
    ]

    resources = [
      "*",
    ]
  }
}


data "aws_iam_policy_document" "ci_user_pass_role" {
  statement {
    actions = [
      "iam:PassRole"
    ]

    resources = [
      aws_iam_role.api_ecs_task_role.arn,
      aws_iam_role.api_ecs_task_execution.arn
    ]
  }
}

resource "aws_iam_user_policy" "ci_user_general" {
  name   = format("%s-ci-user", module.labels.id)
  user   = aws_iam_user.ci_user.name
  policy = data.aws_iam_policy_document.ci_user.json
}

resource "aws_iam_user_policy" "ci_user_lambda" {
  name   = format("%s-ci-user_lambda", module.labels.id)
  user   = aws_iam_user.ci_user.name
  policy = data.aws_iam_policy_document.ci_user_lambda.json
}

resource "aws_iam_user_policy" "ci_user_pass_role" {
  name   = format("%s-ci-user_pass_role", module.labels.id)
  user   = aws_iam_user.ci_user.name
  policy = data.aws_iam_policy_document.ci_user_pass_role.json
}


