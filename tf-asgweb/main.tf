# https://www.terraform.io/docs/configuration/terraform.html
terraform {
  required_version = "~> 0.9"
}

# ------------------------------------------------------------------------------
# CONFIGURE AWS CONNECTION (PROVIDER)
# ------------------------------------------------------------------------------
provider "aws" {
  version    = "~> 1.9"
  region     = "${var.region_uswest2}"
  access_key = "${var.aws_accesskey_uswest2}"
  secret_key = "${var.aws_secretkey_uswest2}"
}

provider "template" {
  version = "~> 1.0"
}

# ROUTE53 -- TODO put this global... just playing now
data "aws_route53_zone" "selected" {
  name         = "notatuna.com."
  private_zone = false
}

# ------------------------------------------------------------------------------
# IAM - POLICIES, ROLES, GROUPS, USERS, etc.
# TODO - move IAM to a base env or module since it is global to all envs
# ------------------------------------------------------------------------------

# Bastion server :
# - function: use IAM role to allow server to reassign its own EIP in ASG for HA

# Role for EIP access
resource "aws_iam_role" "ec2_eip_access" {
  name               = "EC2EIPAccess"
  assume_role_policy = "${file("../tf-global/files/iam/roles/assume-role-policy-ec2.txt")}"
}

# Policy for EIP access
resource "aws_iam_role_policy" "AllowEC2ManageEIP" {
  name   = "AllowEC2ManageEIP"
  role   = "${aws_iam_role.ec2_eip_access.name}"
  policy = "${file("../tf-global/files/iam/roles/policy-allowmanage-eip.txt")}"
}

# Instance profile to attach to the instances
resource "aws_iam_instance_profile" "EC2ManageEIP" {
  name = "EC2ManageEIP"
  role = "${aws_iam_role.ec2_eip_access.name}"
}

# ------------------------------------------------------------------------------
# MODULES
# ------------------------------------------------------------------------------

# -- CREATE vpc, subnets, security groups, eips, network ACLs etc.
module "networking" {
  source = "../terraform-modules/networking"

  #module inputs
  environment                  = "${var.environment}"
  vpc_name                     = "${var.vpc_name}"
  vpc_cidr                     = "${var.vpc_cidr}"
  publicsubnet_cidrs           = ["${var.publicsubnet_one_cidr}", "${var.publicsubnet_two_cidr}"]
  privatesubnet_cidrs          = ["${var.privatesubnet_one_cidr}", "${var.privatesubnet_two_cidr}"]
  availability_zones           = ["${var.azs_uswest2}"]
  database_privatesubnet_cidrs = ["${var.private_db_subnet_one_cidr}", "${var.private_db_subnet_two_cidr}"]
  enable_natgateway            = "true"
  enable_bastion               = "true"

  #TODO - add option for nat instances only for cheap dev/testing env??

  tags {
    # Name tag is handled internally
    "Terraform"   = "true"
    "Role"        = "networking"
    "Department"  = "development"
    "Environment" = "${var.environment}"
  }
}

# -- CREATE bastion server (w/ autoscaling)
module "bastion" {
  source = "../terraform-modules/bastion"

  #module inputs
  environment      = "${var.environment}"
  route53_zoneid   = "${data.aws_route53_zone.selected.zone_id}"
  route53_zonename = "${data.aws_route53_zone.selected.name}"
  bastioneip       = "${module.networking.bastion_elasticip}"
  bastionname      = "bastion"                                   #name to use on all resources

  #can't do this with tags yet, ASGs are special...wait on TF .10 :
  # https://github.com/hashicorp/terraform/pull/13574
  #tags = ""
  asg_subnets = ["${module.networking.public_subnets}"]

  lc_iam_eip_instanceprofile = "${aws_iam_instance_profile.EC2ManageEIP.id}"
  lc_keyname                 = "${var.key_name_uswest2}"

  #lc_keyfile                 = "${var.key_file_uswest2}"
  lc_instanceuser   = "ec2-user"
  lc_imageid        = "${lookup(var.amzlinux_amis, var.region_uswest2)}"
  lc_securitygroups = ["${module.networking.bastion_security_group_id}"]
  lc_userdata       = "${data.template_file.bastion_userdata.rendered}"
}

# -- CREATE webservers cluster (w/ autoscaling)
module "asg_webservers" {
  source = "../terraform-modules/asg_webservers"

  #module inputs
  environment      = "${var.environment}"
  webserversname   = "webservers"                                #name of the webservers in the cluster (be careful here, changing this will cycle the ASG!!)
  tags             = ""                                          #use key value pairs??
  route53_zoneid   = "${data.aws_route53_zone.selected.zone_id}"
  route53_zonename = "${data.aws_route53_zone.selected.name}"
  asg_minsize      = 2
  asg_maxsize      = 4
  asg_elbcapacity  = 2
  asg_subnets      = ["${module.networking.private_subnets}"]
  lc_keyname       = "${var.key_name_uswest2}"

  #lc_keyfile        = "${var.key_file_uswest2}"
  lc_instancetype   = "t2.micro"
  lc_instanceuser   = "ubuntu"
  lc_imageid        = "${var.ami}"
  lc_securitygroups = ["${module.networking.clusterweb_security_group_id}"]

  #lc_userdata        = "${data.template_file.webservers_userdata.rendered}"
  elb_securitygroups = ["${module.networking.clusterweb_elb_security_group_id}"]

  elb_subnets                     = ["${module.networking.public_subnets}"]
  elb_healthythreshold            = 2
  elb_unhealthythreshold          = 2
  elb_healthchecktimeout          = 3
  elb_healthcheckinterval         = 30
  elb_healthchecktarget           = "HTTP:${module.networking.webserver_port}/" #just check the root for now..
  elb_crosszonebalancing          = true
  elb_idle_timeout                = 120
  elb_connection_draining         = true
  elb_connection_draining_timeout = 300

  #
  #--TODO expose elb access logs options here
  #
  # In the case of multiple listeners might have to create diff modules for each
  # TODO - investigate looping with count or something to create/define.
  # Right now just deal with HTTP only
  elb_listener_lb_http_port = "${module.networking.webserver_port}"

  elb_listener_http_instance_port = "${module.networking.webserver_port}"
}

# -- CREATE RDS instance (MySQL)
# module "rds_mysql" {
#   source = "../modules/rds_mysql"


#   #module inputs
#   environment      = "${var.environment}"
#   instancename     = "webservers-rds"
#   tags             = ""
#   allocatedstorage = 10
#   storagetype      = "gp2"
#   instanceclass    = "db.t2.micro"
#   mysql_version    = "5.7.17"
#   mysql_dbname     = "${var.mysql_dbname}"
#   mysql_username   = "${var.mysql_user}"
#   mysql_pwd        = "${var.mysql_pwd}"
#   mysql_port       = 3306
#   securitygroups   = ["${module.networking.rds_security_group_id}"]


#   #dbsubnet_groupname = "${module.networking.rds_subnetgroupone_name}"
#   dbsubnet_groupname = "${module.networking.database_subnet_group_name}"


#   #parameterize this next group per env (e.g. prod vs non-prod)
#   is_multiaz             = false
#   backup_retentionperiod = 1


#   # disable enhanced monitoring with '0' on 'monitoringinterval'
#   monitoringinterval                = 0
#   applychangesimmediately           = ""
#   mysql_allow_major_version_upgrade = false
#   mysql_auto_minor_version_upgrade  = true


#   #if you set 'skipfinalsnapshot' to false, you MUST set 'finalsnapshotidentifier'
#   skipfinalsnapshot       = true
#   finalsnapshotidentifier = "${var.environment}-webservers-rds"
#   maintenancewindow       = "Sat:10:00-Sat:13:00"               #UTC
#   backupwindow            = "08:00-09:00"                       #UTC
# }


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# !!! END OF CONFIG - everything below this is either templates or old !!!
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

