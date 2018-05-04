# ----------------------------------------------------------------------------
# MODULE INPUTS (TF equiv of arguments, params, whatever)
# ----------------------------------------------------------------------------

variable "environment" {
  description = "The current env to build for"
}
variable "vpc_name" {
  description = "The name of the VPC"
  default = ""
}
variable "vpc_cidr" {
  description = "The CIDR range for the VPC"
  default = ""
}
variable "tags" {
  type = "map"
  description = "Tags to assign to resources in the VPC" 
  default = {}
}
variable "publicsubnet_cidrs" {
  type ="list"
  description = "List of the CIDRs of public subnets"
  default = []
}
variable "privatesubnet_cidrs" {
  type= "list"
  description = "List of the CIDRs of private subnets"
  default = []
}
variable "database_privatesubnet_cidrs" {
  type= "list"
  description = "List of the CIDRs of private db subnets"
  default = []
}
variable "availability_zones" {
  type= "list"
  description = "List of the AZs in the current region that you want to use"
  default = []
}

# TODO - add option for nat instances only for cheap dev/testing env??

variable "enable_natgateway" {
  description = "Set this true if you want NAT gateways to be created for private subnets"
  default = false
}
variable "enable_bastion" {
  description = "Set this true if you want bastion to be created"
}


#Deprecated - remove this
# variable "publicsubnet_one_cidr" {
#   description = "The CIDR of public subnet one"

# }
# variable "publicsubnet_one_az" {
#   description = "The AZ assigned to this subnet"
# }
# variable "publicsubnet_two_cidr" {
#   description = "The CIDR of public subnet two"
# }
# variable "publicsubnet_two_az" {
#   description = "The AZ assigned to this subnet"
# }
# variable "privatesubnet_one_cidr" {
#   description = "The CIDR of private subnet one"
# }
# variable "privatesubnet_one_az" {
#   description = "The AZ assigned to this subnet"
# }
# variable "privatesubnet_two_cidr" {
#   description = "The CIDR of private subnet two"
# }
# variable "privatesubnet_two_az" {
#   description = "The AZ assigned to this subnet"
# }
