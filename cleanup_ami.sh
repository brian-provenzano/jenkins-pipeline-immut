#!/bin/bash
if [ $# -ne 4 ]; then
    echo "You are missing args (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY,AWS_DEFAULT_REGION required)"
    exit
fi
export AWS_ACCESS_KEY_ID=$1 
export AWS_SECRET_ACCESS_KEY=$2
export AWS_DEFAULT_REGION=$3
#Find snapshots associated with AMI.
aws ec2 describe-images --image-ids `cat ami.txt` | grep snap | awk ' { print $4 }' > snapami.txt
echo -e "Following are the snapshots associated with ami : `cat snapami.txt`:\n "
echo -e "Deregister the AMI... \n"
aws ec2 deregister-image --image-id `cat ami.txt`
echo -e "\nDeleting the associated snapshots.... \n"
for i in `cat snapami.txt`; do aws ec2 delete-snapshot --snapshot-id $i; done
#echo -e "\nDelete the snapshot holder text file..."
#rm -f snapami.txt

#unset secrets from env
unset AWS_ACCESS_KEY_ID
unset AWS_SECRET_ACCESS_KEY
unset AWS_DEFAULT_REGION