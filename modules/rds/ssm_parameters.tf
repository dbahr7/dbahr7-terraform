# web app env vars
# figure out better place to put this later
resource "aws_ssm_parameter" "CONNECTIONSTRINGS_Membership" {
  name  = "${var.parameter_store_prefix}CONNECTIONSTRINGS_Membership"
  type  = "SecureString"
  value = "Data Source=${aws_db_instance.mssql.address};user=${var.db_username};password=${data.aws_ssm_parameter.db_password.value};database=app_db;enlist=false;"
}

resource "aws_ssm_parameter" "CONNECTIONSTRINGS_AppDb_Membership" {
  name  = "${var.parameter_store_prefix}CONNECTIONSTRINGS_AppDb_Membership"
  type  = "SecureString"
  value = "Data Source=${aws_db_instance.mssql.address};user=${var.db_username};password=${data.aws_ssm_parameter.db_password.value};database=app_db;enlist=false;"
}

resource "aws_ssm_parameter" "CONNECTIONSTRINGS_AppDb_Projects" {
  name  = "${var.parameter_store_prefix}CONNECTIONSTRINGS_AppDb_Projects"
  type  = "SecureString"
  value = "Data Source=${aws_db_instance.mssql.address};user=${var.db_username};password=${data.aws_ssm_parameter.db_password.value};database=app_db;enlist=false;"
}

resource "aws_ssm_parameter" "CONNECTIONSTRINGS_app_dbEntities" {
  name  = "${var.parameter_store_prefix}CONNECTIONSTRINGS_app_dbEntities"
  type  = "SecureString"
  value = "data source=${aws_db_instance.mssql.address};initial catalog=app_db;persist security info=True;user id=${var.db_username};password=${data.aws_ssm_parameter.db_password.value};multipleactiveresultsets=True;application name=EntityFramework"
}

resource "aws_ssm_parameter" "CONNECTIONSTRINGS_app_dbMembershipEntities" {
  name  = "${var.parameter_store_prefix}CONNECTIONSTRINGS_app_dbMembershipEntities"
  type  = "SecureString"
  value = "data source=${aws_db_instance.mssql.address};initial catalog=app_db;persist security info=True;user id=${var.db_username};password=${data.aws_ssm_parameter.db_password.value};multipleactiveresultsets=True;application name=EntityFramework"
}
######################
