# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE RDS MYSQL SECURITY GROUPS
# ---------------------------------------------------------------------------------------------------------------------

# 1 - Security group that is applied RDS instance
resource "aws_security_group" "rds_instance" {
  name = "${var.environment}-rdsmysql"
  vpc_id = "${aws_vpc.main.id}"
  
  # Inbound 3306 from webservers security group
  ingress {
    from_port = "${var.mysql_port}"
    to_port = "${var.mysql_port}"
    protocol = "tcp"
    security_groups = ["${aws_security_group.ssh_web_instance_cluster.id}"]
  }

  tags {
    Name = "${var.environment}-rdsmysql"
    Terraform = "true"
    Department = "development"
    Environment = "${var.environment}"
    Cluster = "none"
    Role = "database"
  }
}