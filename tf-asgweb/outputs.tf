output "bastion_publicip" {
  value = "${module.networking.bastion_elasticip}"
}
output "webcluster_elb_dnsname" {
  value = "${module.asg_webservers.elbcluster_route53_FQDN}"
}
output "bastion_FQDN" {
  value = "${module.bastion.bastion_route53_FQDN}"
}