# https://www.terraform.io/docs/configuration/terraform.html
terraform {
  required_version = "~> 0.9"
}

# ------------------------------------------------------------------------------
# CREATE THE WEBSERVERS ASG/CLUSTER
# ------------------------------------------------------------------------------
# Here’s how you can take advantage of this lifecycle setting to get a zero-downtime deployment:
# 1 - Configure the name parameter of the ASG to depend directly on the name of the launch configuration. 
# That way, each time the launch configuration changes (which it will when you update the AMI or User Data), 
# Terraform will try to replace the ASG.
# 2 - Set the create_before_destroy parameter of the ASG to true, so each time Terraform tries to replace it,
# it will create the replacement before destroying the original.
# 3 - Set the min_elb_capacity parameter of the ASG to the min_size of the cluster so that Terraform will
#  wait for at least that many servers from the new ASG to register in the ELB before it’ll start 
#  destroying the original ASG.
# !!Caveat!! - if ASG dynamically scales this will return you to min value which is bad.  Other alternatives:
# https://github.com/hashicorp/terraform/issues/1552#issuecomment-191847434
# https://github.com/travis-infrastructure/terraform-config/blob/b7584146cfd2b4978def7a87c5f034994cc94766/modules/aws_asg/main.tf#L134-L221
# -- Other thoughts from Terraform Up and Running (http://www.gruntwork.io/about):
# For example, the web server cluster module includes a couple of aws_autoscaling_schedule resources that increase the number of servers in the cluster from 2 to 10 at 9 a.m. If you ran a deployment at, say, 11 a.m., the replacement ASG would boot up with only 2 servers, rather than 10, and would stay that way until 9 a.m. the next day.
# There are several possible workarounds, including:
# Change the recurrence parameter on the aws_autoscaling_schedule from 0 9 * * *, which means “run at 9 a.m.”, to something like 0-59 9-17 * * *, which means “run every minute from 9 a.m. to 5 p.m.” If the ASG already has 10 servers, rerunning this auto scaling policy will have no effect, which is just fine; and if the ASG was just deployed, then running this policy ensures that the ASG won’t be around for more than a minute before the number of Instances is increased to 10. This approach is a bit of a hack, and while it may work for scheduled auto scaling actions, it does not work for auto scaling policies triggered by load (e.g., “add two servers if CPU utilization is over 95%”).
# Create a custom script that uses the AWS API to figure out how many servers are running in the ASG before deployment, use that value as the desired_capacity parameter of the ASG in the Terraform configurations, and then kick off the deployment. After the new ASG has booted, the script should remove the desired_capacity parameter so that the auto scaling policies can control the size of the ASG. On the plus side, the replacement ASG will boot up with the same number of servers as the original, and this approach works with all types of auto scaling policies. The downside is that it requires a custom and somewhat complicated deployment script rather than pure Terraform code.

# 1 - CREATE THE ASG FOR WEBSERVERS
resource "aws_autoscaling_group" "webservers" {
  launch_configuration = "${aws_launch_configuration.webservers.id}"
  # enforce zero downtime deploy: adding lc name to asg name forces recycle 
  # of ASG when lc is recycled
  name = "${var.webserversname}-asg-${aws_launch_configuration.webservers.name}"
  vpc_zone_identifier = ["${var.asg_subnets}"]
  min_size = "${var.asg_minsize}"
  max_size = "${var.asg_maxsize}"
  # enforce zero downtime deploy: set to same size as min_size
  min_elb_capacity = "${var.asg_elbcapacity}"
  load_balancers = ["${aws_elb.webservers.name}"]
  health_check_type = "ELB"

  #enforce zero downtime deploy: depends - create a new ASG before destroying the old one
  lifecycle {
    create_before_destroy = true
  }

  tag {
    key ="Name"
    value ="${var.webserversname}"
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
    value ="webservers"
    propagate_at_launch = "true"
  }
   tag {
    key ="Role"
    value ="web"
    propagate_at_launch = "true"
  }
  tag {
    key ="Environment"
    value ="${var.environment}"
    propagate_at_launch = "true"
  }
}

# 2 - CREATE A WEBSERVERS LAUNCH CONFIGURATION 
resource "aws_launch_configuration" "webservers" {
  name_prefix = "${var.webserversname}-lc-"
  connection={
    user="${var.lc_instanceuser}"
    key_file="${var.lc_keyfile}"
  }
  key_name = "${var.lc_keyname}"
  image_id = "${var.lc_imageid}"
  instance_type = "${var.lc_instancetype}"
  # was having issues with cloud init so falling back to shell script for now
  #user_data = "${file("../global/files/bootstraps/configweb.txt")}"
  user_data =  "${var.lc_userdata}"
  security_groups = ["${var.lc_securitygroups}"]

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
}

# 3 - CREATE AN ELB TO ROUTE TRAFFIC ACROSS THE WEBSERVERS ASG
resource "aws_elb" "webservers" {
  name = "${var.webserversname}-cluster-elb"
  security_groups = ["${var.elb_securitygroups}"]
  subnets = ["${var.elb_subnets}"]
  cross_zone_load_balancing = "${var.elb_crosszonebalancing}"
  idle_timeout = "${var.elb_idle_timeout}"
  connection_draining = "${var.elb_connection_draining}"
  connection_draining_timeout = "${var.elb_connection_draining_timeout}"

  health_check {
    healthy_threshold = "${var.elb_healthythreshold}"
    unhealthy_threshold = "${var.elb_unhealthythreshold}"
    timeout = "${var.elb_healthchecktimeout}"
    interval = "${var.elb_healthcheckinterval}"
    target = "${var.elb_healthchecktarget}"
  }


# # Bucket
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "${var.environment}-${var.webserversname}-cluster-elb.thenuclei.org"
#   versioning {
#       enabled = true
#   }
#   lifecycle{
#       prevent_destroy = true
#   }
#   tags {
#       Name = "TerraformStateBucket"
#       Environment = "global"
#       Department = "development"
#       Terraform = "true"
#   }
# }
  #  access_logs {
  #   bucket = "${var.elb_accesslogs_s3bucket}"
  #   bucket_prefix = "${var.environment}/webservers-cluster-elb"
  #   interval = 60
  #   # TODO consider param this by env??
  #   enabled = true
  # }

  # This adds a listener for incoming HTTP requests.
  listener {
    lb_port = "${var.elb_listener_lb_http_port}"
    lb_protocol = "http"
    instance_port = "${var.elb_listener_http_instance_port}"
    instance_protocol = "http"
  }
  
  #since we set it on ASG, we must set it here (ASG depends on ELB)
  lifecycle {
    create_before_destroy = true
  }

  tags {
    Name = "${var.webserversname}-elb"
    Terraform = "true"
    Department = "development"
    Environment = "${var.environment}"
    Cluster = "webservers"
    Role = "web"
  }
}

#create route53 record entry for elb cluster for easy name access
resource "aws_route53_record" "elbcluster" {
  zone_id = "${var.route53_zoneid}"
  name = "${var.webserversname}.${var.route53_zonename}"
  type = "CNAME"
  ttl = "300"
  records = ["${aws_elb.webservers.dns_name}"]
}