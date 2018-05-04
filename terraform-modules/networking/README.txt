Networking module
---------------------
-Creates VPC, subnets, SGs, NACLS - each in own file
-include at top of main.tf for env
-pass in values located in inputs.tf

NOTE: I like to split out the actual inputs into a separate 'inputs.tf' 
file so you can easily browser/view them.  Just my convention right now...YMMV