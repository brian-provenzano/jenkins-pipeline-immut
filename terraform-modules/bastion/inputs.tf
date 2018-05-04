# ----------------------------------------------------------------------------
# MODULE INPUTS (TF equiv of arguments, params, whatever)
# ----------------------------------------------------------------------------

variable "environment" {
  description = "The current env to build for"
}
variable "bastionname" {
    description = "The name to assign bastion for tags, asg names etc."
}
variable "bastioneip" {
    description  = "The EIP for the bastion that was created by networking module"
}
variable "route53_zonename" {
    description = "The hosted zone name on route53"
}
variable "route53_zoneid" {
    description = "The hosted zoneid on route53"
}
# variable "tags" {
#     type = "map"
#     description = "Tags to assign to ASG" 
# }
variable "asg_subnets" {
    type = "list"
    description = "The subnets to deploy instances into for ASG" 
}
variable "lc_iam_eip_instanceprofile" {
    #needed to allow the bastion HA so it can reassign EIP to itself on boot
    description = "The IAM instance profile for allowing instance to manage EIPs"
}
variable "lc_instanceuser" {
    description = "The username to use for SSH access (this should match to your AMI)"
}
variable "lc_keyname" {
    description = "The name of the key to use for access"
}
variable "lc_keyfile" {
    description = "The path to the key file to use for access"
}
variable "lc_imageid" {
    description = "The AMI to use for the instances"
}
variable "lc_securitygroups" {
    type = "list"
    description = "The security groups to use for instances" 
}
variable "lc_userdata" {
    description = "The userdata to use to configure"
}