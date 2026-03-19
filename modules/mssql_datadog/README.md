# mssql_datadog module
Include this module for MS SQL RDS instances that we want datadog to collect SQL level metrics on.

## initial setup
Reference: https://docs.datadoghq.com/database_monitoring/setup_sql_server/rds/

To push a new image to the repo, follow the login/push commands in the ECR UI. The step to build the image should be:
```
docker build --platform linux/arm64 -t datadog-dbm .
```
