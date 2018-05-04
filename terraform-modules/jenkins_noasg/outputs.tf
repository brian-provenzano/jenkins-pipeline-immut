output "jenkinsmaster_route53_FQDN" {
  value = "${aws_route53_record.jenkins_master.name}"  
}
# output "jenkinsslave_route53_FQDN" {
#   value = "${aws_route53_record.jenkins_slave.name}"  
# }