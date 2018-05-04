# ----------------------------------------------------------------------------
# MODULE INPUTS (TF equiv of arguments, params, whatever)
# ----------------------------------------------------------------------------
variable "environment" {
  description = "The current env to build for"
}

variable "instancename" {
  description = "The name for the RDS instance"
}
variable "tags" {
  description = "The tags for the instance"
}
variable "allocatedstorage" {
  description = "The storage to allocate in GBs"
}
variable "storagetype" {
  description = "The EC2 storage type to use (e.g. gp2, standard, etc)"
}
variable "instanceclass" {
  description = "The EC2 instance class (e.g. db.t2.micro etc)"
}
variable "sqlserver_timezone" {
  description = "The sql server timezone"
}

variable "sqlserver_version" {
  description = "The sql server version"
}
variable "sqlserver_dbname" {
  description = "The sql server database name"
}
variable "sqlserver_username" {
  description = "The sql server username"
}
variable "sqlserver_pwd" {
  description = "The sql server password"
}
variable "sqlserver_port" {
  description = "The sql server port"
}
variable "sqlserver_allow_major_version_upgrade" {
  description = "Allow AWS to upgrade to major versions during maint periods"
}
variable "sqlserver_auto_minor_version_upgrade" {
  description = "Allow AWS to auto upgrade minor versions during maint periods"
}

variable "is_multiaz" {
  description = "The instance is Multi-AZ"
}
variable "backup_retentionperiod" {
  description = "The backup retention period in days"
}
variable "monitoringinterval" {
  description = "The monitoring interval. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60"
}
variable "applychangesimmediately" {
  description = "Apply changes immediately instead of waiting until next maint period"
}
variable "skipfinalsnapshot" {
  description = "Skip the final snapshot of db upon instance terminate. if you set 'skipfinalsnapshot' to false, you MUST set 'finalsnapshotidentifier'"
}
variable "finalsnapshotidentifier" {
  description = "Text id for the final snapshot - if you set 'skipfinalsnapshot' to false, you MUST set 'finalsnapshotidentifier'"
}
variable "securitygroups" {
  type = "list"
  description = "The db security groups"
}
variable "dbsubnet_groupname" {
  description = "The db subnet group name to use for this instance"
}
variable "maintenancewindow" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'. See RDS Maintenance Window docs for more."
}
variable "backupwindow" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenancewindow"
}