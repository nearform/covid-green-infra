# Trigger:
#	Cloudwatch cron schedule
# Resources:
#	KMS
#	RDS
#	Secret manager secrets
#	SSM parameters

module "cleanup" {
  source = "./modules/lambda"
  enable = true
  name   = format("%s-cleanup", module.labels.id)

  aws_parameter_arns = [
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_reader_host.arn,
    aws_ssm_parameter.db_ssl.arn,
    aws_ssm_parameter.security_code_lifetime_mins.arn,
    aws_ssm_parameter.upload_token_lifetime_mins.arn
  ]
  aws_secret_arns                = [data.aws_secretsmanager_secret_version.rds_read_write.arn]
  cloudwatch_schedule_expression = var.cleanup_schedule
  config_var_prefix              = local.config_var_prefix
  handler                        = "cleanup.handler"
  kms_writer_arns                = [aws_kms_key.sqs.arn]
  log_retention_days             = var.logs_retention_days
  memory_size                    = var.lambda_cleanup_memory_size
  s3_bucket                      = var.lambdas_custom_s3_bucket
  s3_key                         = var.lambda_cleanup_s3_key
  security_group_ids             = [module.lambda_sg.id]
  subnet_ids                     = module.vpc.private_subnets
  tags                           = module.labels.tags
  timeout                        = var.lambda_cleanup_timeout
}
