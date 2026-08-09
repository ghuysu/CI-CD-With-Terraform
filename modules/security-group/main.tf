resource "aws_security_group" "this" {
  name        = "${var.project}-${var.environment}-${var.name}-sg"
  vpc_id      = var.vpc_id
  description = var.description

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.environment}-${var.name}-sg"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "this" {
  for_each = {
    for idx, rule in var.ingress_rules :
    idx => rule
  }

  security_group_id            = aws_security_group.this.id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  referenced_security_group_id = length(each.value.security_groups) > 0 ? each.value.security_groups[0] : null
  description                  = try(each.value.description, null)
}

resource "aws_vpc_security_group_egress_rule" "this" {
  for_each = {
    for idx, rule in var.egress_rules :
    idx => rule
  }

  security_group_id            = aws_security_group.this.id
  from_port                    = each.value.from_port
  to_port                      = each.value.to_port
  ip_protocol                  = each.value.protocol
  cidr_ipv4                    = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks[0] : null
  referenced_security_group_id = length(each.value.security_groups) > 0 ? each.value.security_groups[0] : null
  description                  = try(each.value.description, null)
}