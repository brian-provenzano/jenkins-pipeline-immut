#--------------------------------------------------------------------------------
# MODULE INPUTS (TF equiv of arguments, params, whatever)
#--------------------------------------------------------------------------------
variable "environment" {
  description = "The current env to build for - (be careful here, changing this will cycle the ASG, LC, etc!!)"
}

variable "name" {
  description = "The name to use for the web server.  Note changing this will cycle the instance!!"
}

variable "tags" {
  type        = "map"
  description = "Tags to assign"
}

variable "route53_zoneid" {
  description = "The r53 zone id in AWS"
}

variable "route53_zonename" {
  description = "The r53 zone"
}

variable "instanceuser" {
  description = "The user acct on the instance"
}

variable "keyname" {
  description = "The name of the ssh access key for the instance in this region"
}

# variable "keyfile" {
#   description = "The key for ssh access for the instance in this region"
# }

variable "instancetype" {
  description = "The type of instance t2.micro, etc"
}

variable "ami" {
  description = "The ami / image to use for this instance"
}

variable "securitygroups" {
  type        = "list"
  description = "The security groups to create / attach"
}

variable "userdata" {
  description = "The user data for the instance"
}

variable "subnet" {
  description = "The subnet for the instances"
}
