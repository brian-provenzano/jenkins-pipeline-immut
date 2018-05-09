#-----
# initialize the remote state with these values 
# (only need to run this once via terraform init)
#-----
terraform {
  backend "s3" {
    bucket         = "terraform-statefiles.thenuclei.org"
    key            = "simple-webserver-ansibleprovisioner.tfstate"
    region         = "us-west-2"
    encrypt        = "true"
    profile        = "default"
    dynamodb_table = "terraform-locker"
  }
}
