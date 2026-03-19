resource "aws_ssm_parameter" "APPSETTINGS_Site_Name" {
  name  = "${var.parameter_store_prefix}APPSETTINGS_Site_Name"
  type  = "String"
  value = var.site_name
}

resource "aws_ssm_parameter" "APPSETTINGS_Server_Name" {
  name  = "${var.parameter_store_prefix}APPSETTINGS_Server_Name"
  type  = "String"
  value = var.server_name
}

resource "aws_ssm_parameter" "APPSETTINGS_Development_Error_Email_Address" {
  name  = "${var.parameter_store_prefix}APPSETTINGS_Development_Error_Email_Address"
  type  = "String"
  value = "developer@myapp.com"
}

resource "aws_ssm_parameter" "APPSETTINGS_Server_Email_Address" {
  name  = "${var.parameter_store_prefix}APPSETTINGS_Server_Email_Address"
  type  = "String"
  value = "support@myapp.com"
}

resource "aws_ssm_parameter" "APPSETTINGS_Server_URL" {
  name  = "${var.parameter_store_prefix}APPSETTINGS_Server_URL"
  type  = "String"
  value = "https://www.${var.domain}"
}

resource "aws_ssm_parameter" "APPSETTINGS_Site_URL" {
  name  = "${var.parameter_store_prefix}APPSETTINGS_Site_URL"
  type  = "String"
  value = "https://www.${var.domain}"
}

resource "aws_ssm_parameter" "APPSETTINGS_SocketIOAddress" {
  name  = "${var.parameter_store_prefix}APPSETTINGS_SocketIOAddress"
  type  = "String"
  value = "https://session.${var.domain}"
}

resource "aws_ssm_parameter" "bucket_name" {
  name  = "${var.parameter_store_prefix}BUCKET_NAME"
  type  = "String"
  value = var.bucket_name
}
