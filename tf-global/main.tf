##################
# AWS Provider   #
##################
provider "aws"{
    region = "us-west-1"
    profile = "default"
}

# ---------------------------------
# S3 buckets
# ---------------------------------

#TODO - create the route53 domain; s3 bucket; dynamodb table for locking

# TERRAFORM STATE Bucket
# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "terraform-state.thenuclei.org"
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

# ---------------------------------
# Dynamodb tables for locking state
# ---------------------------------

# #TESTING
# resource "aws_dynamodb_table" "terraform_state_tables" {
#   name = "terraform-testing"
#   read_capacity  = 5
#   write_capacity = 5
#   hash_key = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags {
#     Name = "testing-TerraformStateLockTable"
#     Terraform = true
#     Environment = "testing"
#     Department = "development"
#   }
# }

# #MANAGEMENT
# resource "aws_dynamodb_table" "terraform_state_tables" {
#   name = "terraform-management"
#   read_capacity  = 5
#   write_capacity = 5
#   hash_key = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags {
#     Name = "management-TerraformStateLockTable"
#     Terraform = true
#     Environment = "management"
#     Department = "development"
#   }
# }

# #DEVELOPMENT
# resource "aws_dynamodb_table" "terraform_state_tables" {
#   name = "terraform-development"
#   read_capacity  = 5
#   write_capacity = 5
#   hash_key = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags {
#     Name = "development-TerraformStateLockTable"
#     Terraform = true
#     Environment = "development"
#     Department = "development"
#   }
# }


# #PRODUCTION
# resource "aws_dynamodb_table" "terraform_state_tables" {
#   name = "terraform-production"
#   read_capacity  = 5
#   write_capacity = 5
#   hash_key = "LockID"

#   attribute {
#     name = "LockID"
#     type = "S"
#   }

#   tags {
#     Name = "production-TerraformStateLockTable"
#     Terraform = true
#     Environment = "production"
#     Department = "development"
#   }
# }

