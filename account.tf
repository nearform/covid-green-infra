resource "aws_iam_account_password_policy" "password_policy" {
  count = var.create_account_password_policy ? 1 : 0

  allow_users_to_change_password = var.allow_users_to_change_account_password
  max_password_age               = var.account_password_max_age
  minimum_password_length        = var.account_password_minimum_length
  hard_expiry                    = var.account_password_hard_expiry
  password_reuse_prevention      = var.account_password_reuse_prevention
  require_lowercase_characters   = var.account_password_require_lowercase_characters
  require_uppercase_characters   = var.account_password_require_uppercase_characters
  require_numbers                = var.account_password_require_numbers
  require_symbols                = var.account_password_require_symbols
}