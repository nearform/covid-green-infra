resource "aws_sns_topic" "callback_email_notifications" {
  count = local.enable_callback_email_notifications_count

  name              = format("%s-callback-email-notifications", module.labels.id)
  kms_master_key_id = aws_kms_alias.sns.arn
  tags              = module.labels.tags
}

resource "aws_sns_topic" "daily_registrations_reporter" {
  count = local.lambda_daily_registrations_reporter_count

  name              = format("%s-daily-registrations-reporter", module.labels.id)
  kms_master_key_id = aws_kms_alias.sns.arn
  tags              = module.labels.tags
}
