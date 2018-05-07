#environment|testing
# !!! leave line above as is - do not delete (used in our tfwrapper) !!!

###############
# VARIABLES - testing
###############
# TODO - this is nasty
# Clean this up, refactor for more global use, leverage data, remote_state, maps etc (AMIs, regions)
# so we can flip regions and envs easily or whatever else...I need to read/experiment more with TF

variable "environment" {
  description = "Name of environment (testing, development, production, etc)"
  default     = "testing"
}

variable "name" {
  description = "The name for the instance"
}

# ---------------------
# Networking 
# (Testing specific env)
# ---------------------
variable "vpc_name" {
  description = "The name of the VPC"
  default     = "mainvpc"
}

# this range chosen in case we peer with others
variable "vpc_cidr" {
  description = "The CIDR range for the VPC"
  default     = "10.100.0.0/16"
}

variable "publicsubnet_one_cidr" {
  description = "The CIDR of public subnet one"
  default     = "10.100.1.0/24"
}

variable "publicsubnet_two_cidr" {
  description = "The CIDR of public subnet two"
  default     = "10.100.2.0/24"
}

# --------------------------------------------------------------------------------------
# REGIONS (TODO - refactor to global level or something..this is crap)
# --------------------------------------------------------------------------------------

# ---------------------
# US-WEST-1 (CA) region
# ---------------------
# region 
variable "region_uswest1" {
  description = "uswest1 region"
  default     = "us-west-1"
}

# Declare the data source
#data "aws_availability_zones" "available" {}

#AZs for this region
variable "azs_uswest1" {
  type        = "list"
  description = "uswest1 availability zones"
  default     = ["us-west-1a", "us-west-1b"]

  #default = ["${data.aws_availability_zones.available.names}"]
}

# ---Canned AMIs
# TODO - prep a script that automates this to always get latest AMIs for each distro

#custom AMI
variable "custom_ubuntu1604_amis" {
  type = "map"

  default = {
    us-east-2 = ""
    us-west-1 = ""
    us-west-2 = ""
  }
}

# Ubuntu 16.04 LTS
variable "ubuntu1604_amis" {
  type = "map"

  default = {
    us-east-2 = "ami-8b92b4ee"
    us-west-1 = "ami-73f7da13"
    us-west-2 = "ami-835b4efa"
  }
}

# Amazon Linux
variable "amzlinux_amis" {
  default = {
    type      = "map"
    us-east-2 = "ami-8a7859ef"
    us-west-1 = "ami-327f5352"
    us-west-2 = "ami-6df1e514"
  }
}

# CentOS 7 - this is a marketplace AMI (requires presign agreement)
variable "centos7_amis" {
  default = {
    type      = "map"          #new images 1801_01 1/14/2018
    us-east-2 = "ami-18f8df7d" #ami-e1496384
    us-west-1 = "ami-f5d7f195" #ami-65e0e305
    us-west-2 = "ami-f4533694" #ami-a042f4d8
  }
}

# Keys
variable "key_name_uswest1" {
  default = ""
}

#variable "key_file_uswest1" {}
variable "aws_accesskey_uswest1" {
  default = ""
}

variable "aws_secretkey_uswest1" {
  default = ""
}

# ---Our Custom AMIs via Packer
# TODO
variable "ami" {
  description = "The ID of the AMI to deploy"
}

# ---------------------
# US-WEST-2 (OR) region
# ---------------------
# region 
variable "region_uswest2" {
  description = "uswest2 region"
  default     = "us-west-2"
}

#AZs for this region
variable "azs_uswest2" {
  type        = "list"
  description = "uswest2 availability zones"
  default     = ["us-west-2a", "us-west-2b"]

  #default = ["${data.aws_availability_zones.available.names}"]
}

# Keys
variable "key_name_uswest2" {}

#variable "key_file_uswest2" {}

variable "aws_accesskey_uswest2" {}

variable "aws_secretkey_uswest2" {}

# ---------------------
# US-EAST-2 (OH) region
# ---------------------
# region 
variable "region_useast2" {
  description = "useast2 region"
  default     = "us-east-2"
}
