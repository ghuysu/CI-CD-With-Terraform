resource "aws_db_subnet_group" "this" {
  name       = "${var.project}-${var.environment}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.environment}-rds-subnet-group"
    }
  )
}

resource "aws_db_instance" "this" {
  identifier = "${var.project}-${var.environment}-rds"

  engine         = var.engine
  engine_version = var.engine_version

  instance_class        = var.instance_class
  allocated_storage     = var.allocated_storage
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type
  storage_encrypted     = true

  db_name  = var.db_name
  username = var.username
  password = var.password
  port     = var.port

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [var.security_group_id]

  multi_az            = var.multi_az
  publicly_accessible = false

  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  auto_minor_version_upgrade = true
  deletion_protection        = var.deletion_protection
  skip_final_snapshot        = var.skip_final_snapshot
  copy_tags_to_snapshot      = true

  performance_insights_enabled = var.performance_insights_enabled

  tags = merge(
    var.common_tags,
    {
      Name = "${var.project}-${var.environment}-rds"
    }
  )
}