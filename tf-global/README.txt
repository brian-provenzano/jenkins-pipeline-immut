This dir represents our global config for all envs in terraform.  
Put global stuff here (global to all envs).

Definitions:
-/files/bootstraps : contains bootstrap userdata for various instances/launch configs
-/files/misc : misc files, mostly some scripts for grabbing latest AMI versions
    (TODO - region loop through these in some Make script to define)
-/files/iam : IAM policy files