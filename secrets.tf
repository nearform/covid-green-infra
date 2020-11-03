# #########################################
# Secrets - These will already exist
# #########################################
data "aws_secretsmanager_secret_version" "api_gateway_header" {
  secret_id = format("%sheader-x-secret", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "device_check" {
  secret_id = format("%sdevice-check", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "encrypt" {
  secret_id = format("%sencrypt", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "exposures" {
  secret_id = format("%sexposures", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "jwt" {
  secret_id = format("%sjwt", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = format("%srds", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "rds_read_only" {
  secret_id = format("%srds-read-only", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "rds_read_write" {
  secret_id = format("%srds-read-write", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "rds_read_write_create" {
  secret_id = format("%srds-read-write-create", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "verify" {
  secret_id = format("%sverify", local.config_var_prefix)
}

# #########################################
# Optional secrets - These exist for some instances
# #########################################
data "aws_secretsmanager_secret_version" "cct" {
  count     = contains(var.optional_secrets_to_include, "cct") ? 1 : 0
  secret_id = format("%scct", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "cso" {
  count     = contains(var.optional_secrets_to_include, "cso") ? 1 : 0
  secret_id = format("%scso", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "interop" {
  count     = contains(var.optional_secrets_to_include, "interop") ? 1 : 0
  secret_id = format("%sinterop", local.config_var_prefix)
}

data "aws_secretsmanager_secret_version" "sms" {
  count     = contains(var.optional_secrets_to_include, "sms") ? 1 : 0
  secret_id = format("%ssms", local.config_var_prefix)
}
