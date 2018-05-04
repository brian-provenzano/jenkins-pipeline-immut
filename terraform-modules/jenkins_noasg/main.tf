# https://www.terraform.io/docs/configuration/terraform.html
terraform {
  required_version = "~> 0.9"
}

# # ---------------------------------------------------------------------------------------------------------------------
# # DEPLOY A SINGLE EC2 INSTANCE
# # Jenkins Master
# # ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "jenkins_master" {
  connection={
        user="${var.master_instanceuser}"
        key_file="${var.keyfile}"
    }
  ami = "${var.master_ami}"
  instance_type = "${var.master_instancetype}"
  # iam_instance_profile = "${var.master_instanceprofile}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = ["${var.master_securitygroups}"]
  user_data = "${var.master_userdata}"
  subnet_id = "${var.subnet}"
  tags = "${merge(var.tags, map("Name", format("%s", "${var.environment}-${var.mastername}")))}"
}

#create route53 record entry for external access
resource "aws_route53_record" "jenkins_master" {
  zone_id = "${var.route53_zoneid}"
  name = "${var.mastername}.${var.route53_zonename}"
  type = "A"
  ttl = "300"
  records = ["${aws_instance.jenkins_master.public_ip}"]
}

# # ---------------------------------------------------------------------------------------------------------------------
# # Jenkins Slave
# # ---------------------------------------------------------------------------------------------------------------------

resource "aws_instance" "jenkins_slave" {
  connection={
        user="${var.slave_instanceuser}"
        key_file="${var.keyfile}"
    }
  ami = "${var.slave_ami}"
  instance_type = "${var.slave_instancetype}"
  key_name = "${var.keyname}"
  vpc_security_group_ids = ["${var.slave_securitygroups}"]
  user_data = "${var.slave_userdata}"
  subnet_id = "${var.subnet}"
  tags = "${merge(var.tags, map("Name", format("%s", "${var.environment}-${var.slavename}")))}"
}


#create route53 record entry for jenkins slave for name access
# resource "aws_route53_record" "jenkins_slave" {
#   zone_id = "${var.route53_zoneid}"
#   name = "${var.slavename}.${var.route53_zonename}"
#   type = "A"
#   ttl = "300"
#   records = ["${aws_instance.jenkins_slave.public_ip}"]
# }