# # ---------------------------------------------------------------------------------------------------------------------
# # DEPLOY A SINGLE EC2 INSTANCE (Quick and dirty template)
# # ---------------------------------------------------------------------------------------------------------------------
# resource "aws_instance" "singleweb" {
#   connection={
#         user="ubuntu"
#         key_file=""
#     }
##  ubuntu AMI
#   ami = "${lookup(var.ubuntu1604_amis, var.region_uswest1)}"
#   instance_type = "t2.micro"
#   key_name = ""
#   vpc_security_group_ids = [""]
#   user_data = "${file("../global/files/bootstraps/config-ubuntu-simpleinstance.sh")}"
#   subnet_id = ""
#   tags {
#     Name = "SingleWebTestTemplate"
#     Terraform = "true"
#     OS = "Ubuntu"
#     OSVersion = "16.04"
#     Department = "development"
#     Environment = "testing"
#     Role = "web"
#   }
# }