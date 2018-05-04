# https://www.terraform.io/docs/configuration/terraform.html
terraform {
  required_version = "~> 0.9"
}

# 1- CREATE THE ASG FOR BASTION
resource "aws_autoscaling_group" "bastion" {
  launch_configuration = "${aws_launch_configuration.bastion.id}"
  name = "${var.bastionname}-asg"
  vpc_zone_identifier = ["${var.asg_subnets}"]
  # min/max of 1 makes sure we have 1 running at all times
  min_size = 1
  max_size = 1
  health_check_type = "EC2"
  
  tag {
    key ="Name"
    value ="${var.bastionname}"
    propagate_at_launch = "true"
  }
  tag {
    key ="Terraform"
    value ="true"
    propagate_at_launch = "true"
  }
  tag {
    key ="Department"
    value ="development"
    propagate_at_launch = "true"
  }
  tag {
    key ="Cluster"
    value ="none"
    propagate_at_launch = "true"
  }
   tag {
    key ="Role"
    value ="bastion"
    propagate_at_launch = "true"
  }
  tag {
    key ="Environment"
    value ="${var.environment}"
    propagate_at_launch = "true"
  }
}

# 2 - CREATE A BASTION LAUNCH CONFIGURATION 
resource "aws_launch_configuration" "bastion" {
  name_prefix = "${var.bastionname}-lc-"
  connection={
    user="${var.lc_instanceuser}"
    key_file="${var.lc_keyfilepath}"
  }
  iam_instance_profile = "${var.lc_iam_eip_instanceprofile}"
  key_name = "${var.lc_keyname}"
  # use amazon linux for bastions - mainly b/c it comes shipped with aws cli
  image_id = "${var.lc_imageid}"
  instance_type = "t2.micro" #hardcoded on purpose; don't need more than this
  security_groups = ["${var.lc_securitygroups}"]
  user_data =  "${var.lc_userdata}"

  # Important note: whenever using a launch configuration with an auto scaling group, you must set
  # create_before_destroy = true. However, as soon as you set create_before_destroy = true in one resource, you must
  # also set it in every resource that it depends on, or you'll get an error about cyclic dependencies (especially when
  # removing resources). For more info, see:
  #
  # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
  # https://terraform.io/docs/configuration/resources.html
  lifecycle {
    create_before_destroy = true
  }


#testing : hardcode for now - make these configurable inputs!!
  # provisioner "file" {
  # source      = "my.pem"
  # destination = "/home/ec2user/my.pem"

  # connection {
  #   type     = "ssh"
  #   user     = "ec2user"
  #   private_key = "${file("my.pem")}"
  # }
#}

}

#create route53 record entry for bastion for name access
resource "aws_route53_record" "bastion" {
  zone_id = "${var.route53_zoneid}"
  name = "${var.bastionname}.${var.route53_zonename}"
  type = "A"
  ttl = "300"
  records = ["${var.bastioneip}"]
}