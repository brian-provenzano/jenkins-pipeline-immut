terraform {
  required_version = "~>0.9"
}
#--------------------------------------------------------------------------------
# jenkins_asg
#--------------------------------------------------------------------------------
#TODO - jenkins module that deploys master into ASG with ELB, use EFS as the backend store
# slaves as instances launched on demand by master OR better use docker plugin for docker slave containers :)
