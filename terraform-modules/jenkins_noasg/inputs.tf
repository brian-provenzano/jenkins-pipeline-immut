# ----------------------------------------------------------------------------
# MODULE INPUTS (TF equiv of arguments, params, whatever)
# ----------------------------------------------------------------------------

variable "environment" {
  description = "The current env to build for"
}
variable "route53_zonename" {
    description = "The hosted zone name on route53"
}
variable "route53_zoneid" {
    description = "The hosted zoneid on route53"
}

variable "keyname" {
    description = "The name of the key to use for access"
}
variable "keyfile" {
    description = "The path to the key file to use for access"
}
variable "tags" {
    type = "map"
    description = "Tags to assign" 
}
variable "subnet" {
    description = "The subnet for the instances" 
}

# ------
# MASTER
# ------
variable "mastername" {
    description = "Name for the master server" 
}
# variable "master_tags" {
#     type = "map"
#     description = "Tags to assign to master" 
# }
variable "master_instanceuser" {
    description = "The username to use for SSH access (this should match to your AMI)"
}
# variable "master_instanceprofile" {
#     description = "The instance profile for setting rt53 DNS on boot"
# }
variable "master_instancetype" {
    description = "The AWS instance type to use"
}
variable "master_ami" {
    description = "The AMI to use for the instances"
}
variable "master_userdata" {
    description = "The master userdata to use to configure"
}
variable "master_securitygroups" {
    type = "list"
    description = "The security groups to use for instances" 
}
# ------
# SLAVE(s)
# ------
variable "slavename" {
    description = "Name for the master server" 
}
# variable "slave_tags" {
#     type = "map"
#     description = "Tags to assign to master" 
# }
variable "slave_instanceuser" {
    description = "The username to use for SSH access (this should match to your AMI)"
}
variable "slave_instancetype" {
    description = "The AWS instance type to use"
}
variable "slave_ami" {
    description = "The AMI to use for the instances"
}
variable "slave_userdata" {
    description = "The master userdata to use to configure"
}
variable "slave_securitygroups" {
    type = "list"
    description = "The security groups to use for instances" 
}