Bastion server module
---------------------
-Creates single Bastion (jump) server for SSH admin duties in autoscaling group in multi subnet/AZ
-Only allows SSH
-include at top of main.tf for env
-pass in values located in inputs.tf

NOTE: I like to split out the actual inputs into a separate 'inputs.tf' 
file so you can easily browser/view them.  Just my convention right now...YMMV