#Security group for a *simple* jenkins slave
resource "aws_security_group" "jenkinsslave_instance" {
  name = "${var.environment}-jenkinsslave"
  vpc_id = "${aws_vpc.main.id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    security_groups = ["${aws_security_group.jenkinsmaster_instance.id}"]
  }
  # Inbound SSH 
  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["${var.home_publicaddress}"]
  }
  # Inbound ICMP from bastion
  ingress {
    from_port = "${var.icmp_typenumber_ping}"
    to_port = "${var.icmp_code_ping}"
    protocol = "icmp"
    cidr_blocks = ["${var.home_publicaddress}"]
  }
  # All out ALL explicitly b/c TF doesnt do this like AWS console does... ARGH!
  egress {
      from_port = 0
      to_port = 0
      protocol = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }

tags {
    Name = "${var.environment}-jenkinsslave"
    Terraform = "true"
    Department = "development"
    Environment = "${var.environment}"
    Cluster = "bastion"
    Role = "bastion"
  }
}