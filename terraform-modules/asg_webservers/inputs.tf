# ----------------------------------------------------------------------------
# MODULE INPUTS (TF equiv of arguments, params, whatever)
# ----------------------------------------------------------------------------


variable "environment" {
  description = "The current env to build for - (be careful here, changing this will cycle the ASG, LC, etc!!)"
}
variable "webserversname" {
  description = "The name to use for the web servers cluster  assembly (lc,asg,etc).  Note changing this will cycle the ASG!!"
}
variable "tags" {
  description = "The tags to use for the resources"
}
variable "route53_zoneid" {
  description = "The current env to build for"
}
variable "route53_zonename" {
  description = "The current env to build for"
}
variable "asg_minsize" {
  description = "The current env to build for"
}
variable "asg_maxsize" {
  description = "The current env to build for"
}
variable "asg_elbcapacity" {
  description = "The current env to build for"
}
variable "asg_subnets" {
  type = "list"
  description = "The current env to build for"
}
variable "lc_instanceuser" {
  description = "The current env to build for"
}

variable "lc_keyname" {
  description = "The current env to build for"
}
variable "lc_keyfile" {
  description = "The current env to build for"
}
variable "lc_instancetype" {
  description = "The current env to build for"
}
variable "lc_imageid" {
  description = "The current env to build for"
}
variable "lc_securitygroups" {
  type = "list"
  description = "The current env to build for"
}
variable "lc_userdata" {
  description = "The current env to build for"
}
variable "elb_securitygroups" {
  type = "list"
  description = "The current env to build for"
}
variable "elb_subnets" {
  type = "list"
  description = "The current env to build for"
}
variable "elb_healthythreshold" {
  description = "The current env to build for"
}

variable "elb_unhealthythreshold" {
  description = "The current env to build for"
}
variable "elb_healthchecktimeout" {
  description = "The current env to build for"
}
variable "elb_healthcheckinterval" {
  description = "The current env to build for"
}
variable "elb_healthchecktarget" {
  description = "The current env to build for"
}
variable "elb_crosszonebalancing" {
  description = "The current env to build for"
}
variable "elb_idle_timeout" {
  description = "The current env to build for"
}
variable "elb_connection_draining" {
  description = "The current env to build for"
}
variable "elb_connection_draining_timeout" {
  description = "The current env to build for"
}
#
#--TODO expose elb access logs options here
#
# In the case of multiple listeners might have to create diff modules for each
# TODO - investigate looping with count or something to create/define.
# Right now just deal with HTTP only
variable "elb_listener_lb_http_port" {
  description = "The current env to build for"
}
variable "elb_listener_http_instance_port" {
  description = "The current env to build for"
}