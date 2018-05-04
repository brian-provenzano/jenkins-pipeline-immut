#Security group for a *simple* non-clustered web instance with SSH (mostly for testing)
resource "aws_security_group" "ssh_web_instance" {
  name   = "ssh-http-only-restricted"
  vpc_id = "${aws_vpc.main.id}"

  # Inbound HTTPS
  ingress {
    from_port   = "${var.webserver_port}"
    to_port     = "${var.webserver_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.home_publicaddress}"]
  }

  # Inbound HTTP
  ingress {
    from_port   = "${var.webserver_port}"
    to_port     = "${var.webserver_port}"
    protocol    = "tcp"
    cidr_blocks = ["${var.home_publicaddress}"]
  }

  # Inbound SSH from bastion
  ingress {
    from_port       = "${var.ssh_port}"
    to_port         = "${var.ssh_port}"
    protocol        = "tcp"
    security_groups = ["${aws_security_group.ssh_bastion_instance.id}"]
  }

  # Inbound ICMP from bastion
  #   ingress {
  #     from_port       = "${var.icmp_typenumber_ping}"
  #     to_port         = "${var.icmp_code_ping}"
  #     protocol        = "icmp"
  #     security_groups = ["${aws_security_group.ssh_bastion_instance.id}"]
  #   }

  # All out ALL explicitly b/c TF doesnt do this like AWS console does... ARGH!
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
