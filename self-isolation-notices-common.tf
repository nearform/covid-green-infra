resource "aws_ssm_parameter" "enable_self_isolation_notices" {
  name  = format("%s-enable_self_isolation_notices", module.labels.id)
  type  = "String"
  value = var.self_isolation_notices_enabled
}

resource "aws_ssm_parameter" "self_isolation_notices_url" {
  name  = format("%s-self_isolation_notices_url", module.labels.id)
  type  = "String"
  value = var.self_isolation_notices_url
}
