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
# MODULES
# ------------------------------------------------------------------------------

# -- CREATE vpc, subnets, security groups, eips, network ACLs etc.
module "networking" {
  source = "../../terraform-modules/networking"

  #module inputs
  environment        = "${var.environment}"
  vpc_name           = "${var.vpc_name}"
  vpc_cidr           = "${var.vpc_cidr}"
  publicsubnet_cidrs = ["${var.publicsubnet_one_cidr}"]

  #privatesubnet_cidrs          = [""]
  availability_zones = ["${var.azs_uswest2}"]

  #database_privatesubnet_cidrs = [""]
  enable_natgateway = "false"
  enable_bastion    = "false"

  tags {
    # Name tag is handled internally
    "Terraform"   = "true"
    "Role"        = "networking"
    "Department"  = "development"
    "Environment" = "${var.environment}"
  }
}

module "simplewebserver" {
  source = "../../terraform-modules/simplewebserver"

  #module inputs
  environment  = "${var.environment}"
  name         = "${var.name}"
  instanceuser = "ubuntu"
  keyname      = "${var.key_name_uswest2}"

  #keyfile          = "${var.key_file_uswest2}"
  instancetype     = "t2.micro"
  ami              = "${var.ami}"
  securitygroups   = ["${module.networking.simpleweb_security_group_id}"]
  userdata         = ""
  subnet           = "${element(module.networking.public_subnets, 1)}"
  route53_zoneid   = "${data.aws_route53_zone.selected.zone_id}"
  route53_zonename = "${data.aws_route53_zone.selected.name}"

  tags {
    # Name tag is handled internally
    "Terraform"   = "true"
    "Role"        = "webserver"
    "Department"  = "development"
    "Environment" = "${var.environment}"
  }
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# !!! END OF CONFIG 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

