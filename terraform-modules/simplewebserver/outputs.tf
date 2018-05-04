#--------------------------------------------------------------------------------
# MODULE OUTPUTS
#--------------------------------------------------------------------------------
output "route53_FQDN" {
  value = "${aws_route53_record.simplewebserver.name}"
}

output "publicip" {
  value = "${aws_instance.simplewebserver.public_ip}"
}
