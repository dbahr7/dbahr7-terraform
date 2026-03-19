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

resource "aws_ssm_parameter" "APPSETTINGS_RedisConnectionAddress" {
  name  = "${var.parameter_store_prefix}APPSETTINGS_RedisConnectionAddress"
  type  = "String"
  value = "${aws_elasticache_replication_group.valkey.primary_endpoint_address}:6379,abortConnect=false,ssl=true"
}

resource "aws_elasticache_subnet_group" "group" {
  name       = var.replication_group_id
  subnet_ids = data.aws_subnets.private.ids
}

resource "aws_security_group" "valkey_sg" {
  name        = "${var.replication_group_id}-${var.purpose}-valkey"
  description = "${var.replication_group_id} ${var.purpose} security group"
  vpc_id      = data.aws_vpc.main.id
}

resource "aws_elasticache_replication_group" "valkey" {
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  replication_group_id = var.replication_group_id
  description          = var.description

  engine             = "valkey"
  engine_version     = var.engine_version
  node_type          = var.node_type
  num_cache_clusters = 1

  maintenance_window       = "sat:09:00-sat:10:00"
  snapshot_window          = "10:00-11:00"
  snapshot_retention_limit = strcontains(var.environment, "production") ? 7 : 0
  security_group_ids       = [aws_security_group.valkey_sg.id]
  subnet_group_name        = aws_elasticache_subnet_group.group.name

  apply_immediately = true
}
