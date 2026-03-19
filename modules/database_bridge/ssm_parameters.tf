# keypair is in 1password
resource "aws_ssm_parameter" "PUBLIC_KEY" {
  name  = "${var.parameter_store_prefix}PUBLIC_KEY"
  type  = "String"
  value = var.public_key
}

resource "aws_ssm_parameter" "PERMIT_OPEN_HOST_VAR" {
  name  = "${var.parameter_store_prefix}PERMIT_OPEN_HOST_VAR"
  type  = "String"
  value = "DATABASE_HOST"
}

resource "aws_ssm_parameter" "PERMIT_OPEN_PORT_VAR" {
  name  = "${var.parameter_store_prefix}PERMIT_OPEN_PORT_VAR"
  type  = "String"
  value = "DATABASE_PORT"
}

resource "aws_ssm_parameter" "DATABASE_HOST" {
  name  = "${var.parameter_store_prefix}DATABASE_HOST"
  type  = "String"
  value = var.database_host
}

resource "aws_ssm_parameter" "DATABASE_PORT" {
  name  = "${var.parameter_store_prefix}DATABASE_PORT"
  type  = "String"
  value = var.database_port
}
