terraform {
  required_version = "~>0.9"
}

# ---------------------------------------------------------------------------------------------------------------------
# DEPLOY A SINGLE EC2 INSTANCE (Quick and dirty template)
# ---------------------------------------------------------------------------------------------------------------------
resource "aws_instance" "simplewebserver" {
  connection = {
    user     = "${var.instanceuser}"
    key_file = "${var.keyfile}"
  }

  ami                    = "${var.ami}"
  instance_type          = "${var.instancetype}"
  key_name               = "${var.keyname}"
  vpc_security_group_ids = ["${var.securitygroups}"]
  user_data              = "${var.userdata}"
  subnet_id              = "${var.subnet}"
  tags                   = "${merge(var.tags, map("Name", format("%s", "${var.environment}-${var.name}")))}"
}

#create route53 record entry for external access
resource "aws_route53_record" "simplewebserver" {
  zone_id = "${var.route53_zoneid}"
  name    = "${var.name}.${var.route53_zonename}"
  type    = "A"
  ttl     = "300"
  records = ["${aws_instance.simplewebserver.public_ip}"]
}
