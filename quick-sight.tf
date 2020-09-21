# #########################################
# QUICK SIGHT
# Groups created accordingly to:
# https://aws.amazon.com/premiumsupport/knowledge-center/quicksight-redshift-private-connection/
# #########################################
resource "aws_security_group" "quick_sight_sg" {
  count       = var.enable_quick_sight ? 1 : 0
  name        = "${module.labels.id}-quick-sight"
  vpc_id      = module.vpc.vpc_id
  description = lower("${module.labels.id}-quick-sight-service security group")
  tags        = module.labels.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "quick_sight_ingress" {
  count                    = var.enable_quick_sight ? 1 : 0
  description              = "Allows Quick Sight Connections"
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.quick_sight_service_sg[0].id
  security_group_id        = aws_security_group.quick_sight_sg[0].id
}

resource "aws_security_group_rule" "quick_sight_egress" {
  count                    = var.enable_quick_sight ? 1 : 0
  description              = "Allows Quick Sight Connections"
  type                     = "egress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.quick_sight_service_sg[0].id
  security_group_id        = aws_security_group.quick_sight_sg[0].id
}

resource "aws_security_group" "quick_sight_service_sg" {
  count       = var.enable_quick_sight ? 1 : 0
  name        = "${module.labels.id}-quick-sight-service"
  vpc_id      = module.vpc.vpc_id
  description = lower("${module.labels.id}-quick-sight-service security group")
  tags        = module.labels.tags

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "quick_sight_service_ingress" {
  count                    = var.enable_quick_sight ? 1 : 0
  description              = "Allows Quick Sight Connections"
  type                     = "ingress"
  from_port                = 0
  to_port                  = 65535
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.quick_sight_sg[0].id
  security_group_id        = aws_security_group.quick_sight_service_sg[0].id
}

resource "aws_security_group_rule" "quick_sight_service_egress" {
  count                    = var.enable_quick_sight ? 1 : 0
  description              = "Allows Quick Sight Connections"
  type                     = "egress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.quick_sight_sg[0].id
  security_group_id        = aws_security_group.quick_sight_service_sg[0].id
}