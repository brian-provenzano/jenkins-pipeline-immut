#---------------------
# Network ACLs
#---------------------

# Create NACL for an extra layer between open internet and public subnets / bastions
# resource "aws_network_acl" "publicsubnets" {
#   vpc_id = "${aws_vpc.main.id}"
#   subnet_ids = ["${aws_subnet.main_publicsubnet_one.id}","${aws_subnet.main_publicsubnet_two.id}"]

#   egress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "${var.home_publicaddress}"
#     from_port  = 1024
#     to_port    = 65535
#   }

#   ingress {
#     protocol   = "tcp"
#     rule_no    = 100
#     action     = "allow"
#     cidr_block = "${var.home_publicaddress}"
#     from_port  = 22
#     to_port    = 22
#   }

#    # Authorize all ICMP inbound traffic.
#   ingress {
#     protocol = "icmp"
#     rule_no = 200
#     action = "allow"
#     cidr_block = "${var.home_publicaddress}"
#     from_port = -1
#     to_port = -1
#     icmp_type = -1
#     icmp_code = -1
#   }
#   # Authorize all ICMP outbound traffic.
#   egress = {
#     protocol = "icmp"
#     rule_no = 200
#     action = "allow"
#     cidr_block = "${var.home_publicaddress}"
#     from_port = -1
#     to_port = -1
#     icmp_type = -1
#     icmp_code = -1
#   }

#   tags {
#     Name = "PublicSubnetsBastion"
#     Terraform = "true"
#     Department = "development"
#     Environment = "testing"
#   }
# }