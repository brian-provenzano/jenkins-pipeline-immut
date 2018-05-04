# Test Pipeline


## Jenkins Declarative Pipeline Example (with packer, terraform, aws, ansible)

NOTE: This can be used with my custom Jenkins containers : [jenkins docker alpine](https://github.com/brian-provenzano/jenkins-alpine-container) and [jenkins docker debian](https://github.com/brian-provenzano/jenkins-container)

### Details
Contains simple Jenkins pipeline that does the following:
- Create a custom AWS AMI using Packer; Ansible provisioner to config the image
- Terraform creates the infra on AWS (simple web server for now)
- Options to tear down TF infra and Packer AMI when done to avoid charges and stay in the good blessings of the free tier


#### Pipeline Job parameters / options:
- Cleanup TF infra when done
- Cleanup custom AMI when done
- Use jenkins credentials store for credentials


### TODO
- packer build AMI in AWS with code baked; currently only configures a static instance of Apache
- expand to use ASG with bastion (my TF modules are built just need to do this)
- sep out the terraform, ansible, packer Iaac/config into seperate repos and pull those directly as part of pipeline instead of packing into one repo??

