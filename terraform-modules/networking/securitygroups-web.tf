# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE WEBSERVERS SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------

# 1 - Security group that is applied to each web instance in ASG (behind ELB)
resource "aws_security_group" "ssh_web_instance_cluster" {
  name = "${var.environment}-webservers"
  vpc_id = "${aws_vpc.main.id}"
  
   # Inbound HTTP
  ingress {
    from_port = "${var.webserver_port}"
    to_port = "${var.webserver_port}"
    protocol = "tcp"
    security_groups = ["${aws_security_group.webservers_elb.id}"]
  }
  # Inbound SSH from bastion
  ingress {
    from_port = "${var.ssh_port}"
    to_port = "${var.ssh_port}"
    protocol = "tcp"
    security_groups = ["${aws_security_group.ssh_bastion_instance.id}"]
  }
  # Inbound ICMP from bastion
  ingress {
    from_port = "${var.icmp_typenumber_ping}"
    to_port = "${var.icmp_code_ping}"
    protocol = "icmp"
    security_groups = ["${aws_security_group.ssh_bastion_instance.id}"]
  }
  # All out ALL explicitly b/c TF doesnt do this... ARGH!
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
    Name = "${var.environment}-webservers"
    Terraform = "true"
    Department = "development"
    Environment = "${var.environment}"
    Cluster = "webservers"
    Role = "web"
  }
}

# 2 - Security group for webserver cluster ELB (applied to the ELB attached to the ASG)
resource "aws_security_group" "webservers_elb" {
  name = "${var.environment}-webservers_elb"
  vpc_id = "${aws_vpc.main.id}"
  # Allow all outbound
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Inbound HTTP
  ingress {
    from_port = "${var.webserver_port}"
    to_port = "${var.webserver_port}"
    protocol = "tcp"
    cidr_blocks = ["${var.home_publicaddress}"]
  }
  
  #ELB has this set and it depends on this SG
  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.environment}-webservers_elb"
    Terraform = "true"
    Department = "development"
    Environment = "${var.environment}"
    Cluster = "webservers"
    Role = "web"
  }
}
