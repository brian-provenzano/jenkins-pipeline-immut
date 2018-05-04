# ------------------------------------------------------------------------------
# CREATE RDS INSTANCE
# helpful reference exsp for SQL Server params
# http://docs.aws.amazon.com/AmazonRDS/latest/APIReference/API_CreateDBInstance.html
# ------------------------------------------------------------------------------

# https://www.terraform.io/docs/configuration/terraform.html
terraform {
  required_version = "~> 0.9"
}

resource "aws_db_instance" "rds_sqlserverexpress" {
  allocated_storage = "${var.allocatedstorage}"
  storage_type = "${var.storagetype}" #20 is min
  instance_class = "${var.instanceclass}"

  engine = "sqlserver-ex"
  engine_version = "${var.sqlserver_version}"
  name = "${var.mysql_dbname}"
  username = "${var.mysql_username}"
  password = "${var.mysql_pwd}"
  port = "${var.mysql_port}"
  timezone = "${var.sqlserver_timezone}"

  multi_az = "${var.is_multiaz}"
  apply_immediately = "${var.applychangesimmediately}"
  # there is a bug in TF (at least as of 0.9.11) - only way to easily fix is mod state file,
  # so make sure 'skip_final_snapshot' is always defined on first plan/apply/destroy...
  # See https://github.com/hashicorp/terraform/issues/5417
  skip_final_snapshot = "${var.skipfinalsnapshot}"
  final_snapshot_identifier = "${var.finalsnapshotidentifier}"
  vpc_security_group_ids = ["${var.securitygroups}"]
  publicly_accessible = false # blackbox this - ALWAYS PRIVATE!!
  db_subnet_group_name = "${var.dbsubnet_groupname}"
  backup_retention_period = "${var.backup_retentionperiod}"
  monitoring_interval = "${var.monitoringinterval}"
  allow_major_version_upgrade = "${var.mysql_allow_major_version_upgrade}"
  auto_minor_version_upgrade = "${var.mysql_auto_minor_version_upgrade}"
  maintenance_window = "${var.maintenancewindow}"
  backup_window = "${var.backupwindow}"

  tags {
    Name = "${var.instancename}"
    Terraform = "true"
    Department = "development"
    Environment = "${var.environment}"
    Cluster = "none"
    Role = "database"
    Database = "true"
  }
}