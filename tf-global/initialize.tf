#-----
# initialize the remote state with these values (only need to run this once via terraform init)
#-----

terraform {
  backend "s3" {
    bucket = "terraform-state.thenuclei.org"
    key    = "global.tfstate"
    region = "us-west-1"
    encrypt = "true"
    profile = "default"
    # no lock we are creating dynamodb tables for locking in this global config
    # we are only run this rarely so skip locking
    #dynamodb_table = "terraform-global"
  }
}