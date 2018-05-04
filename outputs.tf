output "webserver_publicip" {
  value = "${module.simplewebserver.publicip}"
}

output "webserver_dnsname" {
  value = "${module.simplewebserver.route53_FQDN}"
}
