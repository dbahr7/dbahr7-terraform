data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

# Password is managed outside of TF
data "aws_ssm_parameter" "db_password" {
  name = "${var.parameter_store_prefix}MSSQL_PWD"
}

resource "aws_ssm_parameter" "db_username" {
  name  = "${var.parameter_store_prefix}USER"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "cluster_writer_endpoint" {
  name  = "${var.parameter_store_prefix}MSSQL_HOST"
  type  = "String"
  value = aws_db_instance.mssql.address
}

data "aws_vpc" "main" {
  tags = {
    Name = var.vpc_name
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.main.id]
  }

  filter {
    name   = "tag:Tier"
    values = ["private-data"]
  }

  lifecycle {
    postcondition {
      condition     = length(self.ids) >= 3
      error_message = "There should be at least 3 private-data subnets"
    }
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.instance_name}-${var.purpose}"
  subnet_ids = data.aws_subnets.private.ids
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.instance_name}-${var.purpose}-rds"
  description = "${var.instance_name} ${var.purpose} security group"
  vpc_id      = data.aws_vpc.main.id
}

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "enhanced_monitoring" {
  count = var.monitoring_interval > 0 ? 1 : 0
  name  = "${var.instance_name}-rds-enhanced-monitoring"

  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring" {
  count      = var.monitoring_interval > 0 ? 1 : 0
  role       = aws_iam_role.enhanced_monitoring[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}

resource "aws_db_instance" "mssql" {
  identifier = var.instance_name
  username   = var.db_username
  password   = data.aws_ssm_parameter.db_password.value

  allocated_storage = var.storage
  storage_type      = "gp3"
  storage_encrypted = true

  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class
  license_model  = "license-included"

  maintenance_window          = "Sat:08:00-Sat:08:45"
  allow_major_version_upgrade = true
  apply_immediately           = var.apply_immediately
  deletion_protection         = true

  backup_retention_period = strcontains(var.environment, "production") ? 35 : 7
  backup_window           = "07:00-07:45"
  copy_tags_to_snapshot   = true
  skip_final_snapshot     = true

  database_insights_mode       = "standard"
  performance_insights_enabled = true
  monitoring_interval          = var.monitoring_interval
  monitoring_role_arn          = var.monitoring_interval > 0 ? aws_iam_role.enhanced_monitoring[0].arn : null

  multi_az               = strcontains(var.environment, "production")
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  publicly_accessible    = false
  option_group_name      = aws_db_option_group.mssql.name

  depends_on = [
    aws_iam_role_policy_attachment.enhanced_monitoring
  ]
}
