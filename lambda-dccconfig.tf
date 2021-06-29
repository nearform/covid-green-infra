
module "dccconfig" {
  source = "./modules/lambda"
  enable = true
  name   = format("%s-sms-scheduler", module.labels.id)

  aws_parameter_arns = concat([
    aws_ssm_parameter.time_zone.arn,
    aws_ssm_parameter.s3_assets_bucket.arn,
    aws_ssm_parameter.enable_dcc.arn
    ],
    aws_ssm_parameter.interop_origin.*.arn
  )  

  aws_secret_arns    = concat([data.aws_secretsmanager_secret_version.rds_read_write.arn], data.aws_secretsmanager_secret_version.interop.*.arn)
  config_var_prefix  = local.config_var_prefix
  handler            = "dcc-config.handler"
  layers             = lookup(var.lambda_custom_runtimes, "dccconfig", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["dccconfig"].layers
  log_retention_days = var.logs_retention_days
  memory_size        = var.lambda_dccconfig_memory_size
  runtime            = lookup(var.lambda_custom_runtimes, "dccconfig", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["dccconfig"].runtime
  security_group_ids = [module.lambda_sg.id]
  subnet_ids         = module.vpc.private_subnets
  tags               = module.labels.tags
  timeout            = var.lambda_dccconfig_timeout
  cloudwatch_schedule_expression = var.dccconfig_schedule
}
