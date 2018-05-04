#Security group for a *simple* jenkins master
resource "aws_security_group" "jenkinsmaster_instance" {
  name = "${var.environment}-jenkinsmaster"
  vpc_id = "${aws_vpc.main.id}"
  # Inbound HTTP for jenkins
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    # our address then ALL githubs addresses - listed here:
    # https://help.github.com/articles/github-s-ip-addresses/
    cidr_blocks = ["${var.home_publicaddress}","192.30.252.0/22","185.199.108.0/22"]
  }
  # Inbound HTTP for apache "deploy to" test - remove this later if desired
  # lock to our IP for safety though just as above
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["${var.home_publicaddress}","10.101.1.0/24","52.53.158.92/32"]
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
    Name = "${var.environment}-jenkinsmaster"
    Terraform = "true"
    Department = "development"
    Environment = "${var.environment}"
    Cluster = "bastion"
    Role = "bastion"
  }
}