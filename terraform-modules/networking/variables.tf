# TODO - clean this up refactor for more glbal use, leverage data, remote_state, maps etc (AMIs, regions)
# so we can flip regions easily or whatever else...

#ports
variable "webserver_port" {
  description = "The port the server will use for HTTP requests"
  default     = 80
}

variable "webserver_port_https" {
  description = "The port the server will use for HTTPS requests"
  default     = 443
}

variable "ssh_port" {
  description = "The port the server will use for SSH"
  default     = 22
}

variable "mysql_port" {
  description = "The port the rds mysql will use"
  default     = 3306
}

variable "home_publicaddress" {
  description = "the current home IP address I am running terraform from that is used for access in SGs"
  default     = "67.169.149.85/32"
}

variable "icmp_typenumber_ping" {
  description = "The type number for icmp - ping echos"
  default     = 8
}

variable "icmp_code_ping" {
  description = "The code for icmp - ping echos"
  default     = 0
}
