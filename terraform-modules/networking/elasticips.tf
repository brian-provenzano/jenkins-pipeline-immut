
#Bastion elastic IP used in ASG 1:1 for bastion server
resource "aws_eip" "bastion" {
  count = "${var.enable_bastion == true ? 1 : 0}"
  vpc = true
}
#Bastion elastic IP used for nat gateway
resource "aws_eip" "nat_gw" {
  count = "${var.enable_natgateway == true ? 1 : 0}"
  vpc = true
}