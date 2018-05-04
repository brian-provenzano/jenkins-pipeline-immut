output "bastion_route53_FQDN" {
  value = "${aws_route53_record.bastion.name}"  
}