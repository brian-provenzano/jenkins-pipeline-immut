# https://www.terraform.io/docs/configuration/terraform.html
terraform {
  required_version = "~> 0.9"
}

# ---------------------------------------------------------------------------------------------------------------------
# CREATE THE VPC AND SUBNETS
# ---------------------------------------------------------------------------------------------------------------------

#The main VPC
resource "aws_vpc" "main" {
  cidr_block = "${var.vpc_cidr}"
  tags       = "${merge(var.tags, map("Name", format("%s", "${var.environment}-${var.vpc_name}")))}"
}

# Create an internet gateway; attach to the VPC
resource "aws_internet_gateway" "main_igw" {
  vpc_id = "${aws_vpc.main.id}"
  tags   = "${merge(var.tags, map("Name", format("%s", "${var.environment}-${var.vpc_name}-ugw")))}"
}

# Grant the VPC internet access on its route table
resource "aws_route" "main_internet_access" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.main_igw.id}"
  depends_on             = ["aws_route_table.public"]
}

#Create "PUBLIC" route table
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"
  tags   = "${merge(var.tags, map("Name", format("%s", "${var.environment}-${var.vpc_name}-public-route")))}"
}

resource "aws_route_table_association" "associate_pub" {
  count          = "${length(var.publicsubnet_cidrs)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

# Associate public subnets with public route table
# resource "aws_route_table_association" "associate_pub1" {
#   subnet_id = "${aws_subnet.main_publicsubnet_one.id}"
#   route_table_id = "${aws_route_table.public.id}"
# }
# resource "aws_route_table_association" "associate_pub2" {
#   subnet_id = "${aws_subnet.main_publicsubnet_two.id}"
#   route_table_id = "${aws_route_table.public.id}"
# }

# Create a "PRIVATE" route table.
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.main.id}"
  tags   = "${merge(var.tags, map("Name", format("%s", "${var.environment}-${var.vpc_name}-private-route")))}"
}

resource "aws_route_table_association" "associate_prv" {
  count          = "${length(var.privatesubnet_cidrs)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

# NAT hardcode limiting this 1 only ONE NAT gateway in ONE Public subnet for cost reasons for now (testing)
# NAT gateway so that private subnet has internet
resource "aws_nat_gateway" "nat_gw" {
  count         = "${var.enable_natgateway == true ? 1 : 0}"
  allocation_id = "${aws_eip.nat_gw.id}"
  subnet_id     = "${aws_subnet.public.0.id}"                #hard one subnet '0' - TODO after test change to ternary operator for if/then so no hardcode
  depends_on    = ["aws_internet_gateway.main_igw"]
}

# add a nat gateway route table - make this an option on this module (boolean)
resource "aws_route" "private_nat_gateway_route" {
  count                  = "${var.enable_natgateway == true ? 1 : 0}"
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  depends_on             = ["aws_route_table.private"]
  nat_gateway_id         = "${aws_nat_gateway.nat_gw.id}"
}

# --------------
# PUBLIC SUBNETS 
# --------------
resource "aws_subnet" "public" {
  count                   = "${length(var.publicsubnet_cidrs)}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.publicsubnet_cidrs[count.index]}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  tags                    = "${merge(var.tags, map("Name", format("%s-publicsubnet-%s", "${var.environment}-${var.vpc_name}", element(var.availability_zones, count.index))))}"
  map_public_ip_on_launch = true
}

# # Create public subnet one
# resource "aws_subnet" "main_publicsubnet_one" {
#   vpc_id = "${aws_vpc.main.id}"
#   cidr_block = "${var.publicsubnet_one_cidr}"
#   map_public_ip_on_launch = true
#   availability_zone = "${var.publicsubnet_one_az}"
#   tags {
#     Name = "${var.environment}-${var.vpc_name}-publicsubnet-one"
#     Terraform = "true"
#     Role = "networking"
#     Department = "development"
#     Environment = "${var.environment}"
#   }
# }
# # Create public subnet two
# resource "aws_subnet" "main_publicsubnet_two" {
#   vpc_id = "${aws_vpc.main.id}"
#   cidr_block = "${var.publicsubnet_two_cidr}"
#   map_public_ip_on_launch = true
#   availability_zone = "${var.publicsubnet_two_az}"
#   tags {
#     Name = "${var.environment}-${var.vpc_name}-publicsubnet-two"
#     Terraform = "true"
#     Role = "networking"
#     Department = "development"
#     Environment = "${var.environment}"
#   }
# }

# --------------
# PRIVATE SUBNETS (NOT DATABASE) 
# --------------
resource "aws_subnet" "private" {
  #count                   = "${length(var.privatesubnet_cidrs)}"
  count                   = "${length(var.privatesubnet_cidrs) > 0 ? 1 : 0}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.privatesubnet_cidrs[count.index]}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  tags                    = "${merge(var.tags, map("Name", format("%s-privatesubnet-%s", "${var.environment}-${var.vpc_name}", element(var.availability_zones, count.index))))}"
  map_public_ip_on_launch = false
}

# Create private subnet one
# resource "aws_subnet" "main_privatesubnet_one" {
#   vpc_id = "${aws_vpc.main.id}"
#   cidr_block = "${var.privatesubnet_one_cidr}"
#   map_public_ip_on_launch = false
#   availability_zone = "${var.privatesubnet_one_az}"
#   tags {
#     Name = "${var.environment}-${var.vpc_name}-privatesubnet-one"
#     Terraform = "true"
#     Role = "networking"
#     Department = "development"
#     Environment = "${var.environment}"
#   }
# }
# # Create private subnet two
# resource "aws_subnet" "main_privatesubnet_two" {
#   vpc_id = "${aws_vpc.main.id}"
#   cidr_block = "${var.privatesubnet_two_cidr}"
#   map_public_ip_on_launch = false
#   availability_zone = "${var.privatesubnet_two_az}"
#   tags {
#     Name = "${var.environment}-${var.vpc_name}-privatesubnet-two"
#     Terraform = "true"
#     Role = "networking"
#     Department = "development"
#     Environment = "${var.environment}"
#   }
# }

# --------------
# DATABASE PRIVATE SUBNETS AND GROUPS 
# --------------
# Private subnets (DB only)
resource "aws_subnet" "private_database" {
  #count = "${length(var.database_privatesubnet_cidrs)}"
  count                   = "${length(var.database_privatesubnet_cidrs) > 0 ? 1 : 0}"
  vpc_id                  = "${aws_vpc.main.id}"
  cidr_block              = "${var.database_privatesubnet_cidrs[count.index]}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  tags                    = "${merge(var.tags, map("Name", format("%s-db-subnet-%s", "${var.environment}-${var.vpc_name}", element(var.availability_zones, count.index))))}"
  map_public_ip_on_launch = false
}

# RDS DB subnet groups
resource "aws_db_subnet_group" "database_group" {
  count      = "${length(var.database_privatesubnet_cidrs) > 0 ? 1 : 0}"
  name       = "${var.vpc_name}-rds-subnetgroup"
  subnet_ids = ["${aws_subnet.private_database.*.id}"]
  tags       = "${merge(var.tags, map("Name", format("%s-db-subnetgroup", "${var.environment}-${var.vpc_name}")))}"
}

#RDS DB subnet groups
# resource "aws_db_subnet_group" "main_dbsubnetgroup_one" {
#   name = "main-dbsubnetgroup-one"
#   #TODO - create another set of private subnets for db network (don't reuse web subnet)
#   subnet_ids = ["${aws_subnet.main_privatesubnet_one.id}","${aws_subnet.main_privatesubnet_two.id}"]
#   tags {
#     Name = "${var.environment}-${var.vpc_name}-dbsubnetgroup-one"
#     Terraform = "true"
#     Role = "networking"
#     Department = "development"
#     Environment = "${var.environment}"
#     Database = "true"
#   }
# }

