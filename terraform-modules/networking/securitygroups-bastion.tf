# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE BASTION SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------
# 1 - Security group for a bastion instance with SSH
resource "aws_security_group" "ssh_bastion_instance" {
  name = "${var.environment}-bastion"
  vpc_id = "${aws_vpc.main.id}"
  # Inbound SSH
  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    cidr_blocks = ["${var.home_publicaddress}"]
  }
  # Inbound ICMP
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

  # aws_launch_configuration.launch_configuration in this module sets create_before_destroy to true, which means
  # everything it depends on, including this resource, must set it as well, or you'll get cyclic dependency errors
  # when you try to do a terraform destroy.
  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.environment}-bastion"
    Terraform = "true"
    Department = "development"
    Environment = "${var.environment}"
    Cluster = "bastion"
    Role = "bastion"
  }
  
}