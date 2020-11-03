# #########################################
# SQS
# See for KMS usage https://github.com/xpolb01/terraform-encrypted-sqs-sns/blob/master/sqs.tf
# #########################################
resource "aws_sqs_queue" "callback" {
  name              = format("%s-callback", module.labels.id)
  kms_master_key_id = aws_kms_alias.sqs.arn
  tags              = module.labels.tags
  # AWS recommends setting vis_timeout to _at least_ lambda_timeout * 6
  # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-queueconfig
  visibility_timeout_seconds = var.lambda_callback_timeout * 6
}

resource "aws_sqs_queue" "sms" {
  name              = format("%s-sms", module.labels.id)
  kms_master_key_id = aws_kms_alias.sqs.arn
  tags              = module.labels.tags
  # AWS recommends setting vis_timeout to _at least_ lambda_timeout * 6
  # https://docs.aws.amazon.com/lambda/latest/dg/with-sqs.html#events-sqs-queueconfig
  visibility_timeout_seconds = var.lambda_sms_timeout * 6
}
