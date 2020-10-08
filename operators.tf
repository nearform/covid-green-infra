# #########################################
# Operators - group with restricted privileges
# See https://alestic.com/2015/10/aws-iam-readonly-too-permissive/
# #########################################
data "aws_iam_policy_document" "operators" {
  statement {
    actions = [
      "lambda:InvokeFunction"
    ]
    resources = concat([
      aws_lambda_function.callback.arn,
      aws_lambda_function.exposures.arn,
      aws_lambda_function.stats.arn,
      aws_lambda_function.settings.arn,
      aws_lambda_function.token.arn
      ],
      aws_lambda_function.cso.*.arn,
      compact([module.daily_registrations_reporter.function_arn, module.download.function_arn, module.upload.function_arn])
    )
  }

  # Explicitly deny anything on authorizer as it contains a secret
  statement {
    actions = [
      "lambda:*"
    ]
    resources = [
      aws_lambda_function.authorizer.arn,
    ]
    effect = "Deny"
  }

  # Allow getting the RDS read_only_user credentials secret
  statement {
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = [data.aws_secretsmanager_secret_version.rds_read_only.arn]
  }

  # Allow own MFA management
  # See https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_examples_aws_my-sec-creds-self-manage.html
  # For the $${user_name} escaping see https://github.com/terraform-providers/terraform-provider-aws/issues/5984#issuecomment-424470589
  statement {
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice"
    ]
    resources = [format("arn:aws:iam::%s:mfa/$${aws:username}", data.aws_caller_identity.current.account_id)]
    sid       = "AllowManageOwnVirtualMFADevice"
  }
  statement {
    actions = [
      "iam:DeactivateMFADevice",
      "iam:EnableMFADevice",
      "iam:ListMFADevices",
      "iam:ResyncMFADevice"
    ]
    resources = [format("arn:aws:iam::%s:user/$${aws:username}", data.aws_caller_identity.current.account_id)]
    sid       = "AllowManageOwnUserMFA"
  }

  # Conditional
  # PENDING: This works from the CLI without autoscaling:UpdateAutoScalingGroup but we need autoscaling:UpdateAutoScalingGroup to work in the console
  # autoscaling:UpdateAutoScalingGroup is too permissive
  dynamic statement {
    for_each = toset(aws_autoscaling_group.bastion.*.arn)
    content {
      actions = [
        "autoscaling:SetDesiredCapacity",
        "autoscaling:TerminateInstanceInAutoScalingGroup",
        "autoscaling:UpdateAutoScalingGroup"
      ]
      resources = [statement.key]
    }
  }

  # Conditional
  dynamic statement {
    for_each = toset(aws_autoscaling_group.bastion.*.name)
    content {
      actions = [
        "ssm:StartSession"
      ]
      resources = ["arn:aws:ec2:*:*:instance/*"]
      condition {
        test     = "StringEquals"
        values   = [statement.key]
        variable = "ssm:resourceTag/aws:autoscaling:groupName"
      }
    }
  }
}

data "aws_iam_policy_document" "operators_mfa" {
  statement {
    sid    = "AllowAllUsersToListAccounts"
    effect = "Allow"
    actions = [
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListVirtualMFADevices",
      "iam:GetAccountPasswordPolicy",
      "iam:GetAccountSummary"
    ]
    resources = [
      "*"
    ]
  }

  statement {
    sid    = "AllowIndividualUserToSeeAndManageOnlyTheirOwnAccountInformation"
    effect = "Allow"
    actions = [
      "iam:ChangePassword",
      "iam:CreateAccessKey",
      "iam:CreateLoginProfile",
      "iam:DeleteAccessKey",
      "iam:DeleteLoginProfile",
      "iam:GetLoginProfile",
      "iam:ListAccessKeys",
      "iam:UpdateAccessKey",
      "iam:UpdateLoginProfile",
      "iam:ListSigningCertificates",
      "iam:DeleteSigningCertificate",
      "iam:UpdateSigningCertificate",
      "iam:UploadSigningCertificate",
      "iam:ListSSHPublicKeys",
      "iam:GetSSHPublicKey",
      "iam:DeleteSSHPublicKey",
      "iam:UpdateSSHPublicKey",
      "iam:UploadSSHPublicKey"
    ]
    resources = [
      "arn:aws:iam::*:user/&{aws:username}"
    ]
  }

  statement {
    sid    = "AllowIndividualUserToListOnlyTheirOwnMFA"
    effect = "Allow"
    actions = [
      "iam:ListMFADevices"
    ]
    resources = [
      "arn:aws:iam::*:mfa/*",
      "arn:aws:iam::*:user/&{aws:username}"
    ]
  }

  statement {
    sid    = "AllowIndividualUserToManageTheirOwnMFA"
    effect = "Allow"
    actions = [
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:mfa/&{aws:username}",
      "arn:aws:iam::*:user/&{aws:username}"
    ]
  }

  statement {
    sid    = "AllowIndividualUserToDeactivateOnlyTheirOwnMFAOnlyWhenUsingMFA"
    effect = "Allow"
    actions = [
      "iam:DeactivateMFADevice"
    ]
    resources = [
      "arn:aws:iam::*:mfa/&{aws:username}",
      "arn:aws:iam::*:user/&{aws:username}"
    ]
    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values = [
        "true"
      ]
    }
  }

  statement {
    sid    = "BlockMostAccessUnlessSignedInWithMFA"
    effect = "Deny"
    not_actions = [
      "iam:ChangePassword",
      "iam:CreateLoginProfile",
      "iam:CreateVirtualMFADevice",
      "iam:DeleteVirtualMFADevice",
      "iam:ListVirtualMFADevices",
      "iam:EnableMFADevice",
      "iam:ResyncMFADevice",
      "iam:ListAccountAliases",
      "iam:ListUsers",
      "iam:ListSSHPublicKeys",
      "iam:ListAccessKeys",
      "iam:ListServiceSpecificCredentials",
      "iam:ListMFADevices",
      "iam:GetAccountSummary",
      "sts:GetSessionToken"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "BoolIfExists"
      variable = "aws:MultiFactorAuthPresent"
      values = [
        "false",
      ]
    }
  }
}

resource "aws_iam_group" "operators" {
  name = format("%s-%s", module.labels.id, "operators")
  path = "/"
}

resource "aws_iam_group_policy" "operators" {
  group  = aws_iam_group.operators.id
  name   = format("%s-%s", module.labels.id, "operators")
  policy = data.aws_iam_policy_document.operators.json
}

resource "aws_iam_group_policy" "operators_mfa" {
  group  = aws_iam_group.operators.id
  name   = format("%s-%s", module.labels.id, "operators-mfa")
  policy = data.aws_iam_policy_document.operators_mfa.json
}

resource "aws_iam_group_policy_attachment" "operators" {
  group      = aws_iam_group.operators.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}